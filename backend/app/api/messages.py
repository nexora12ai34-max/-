"""
Messaging and chat endpoints
Real-time message delivery, read receipts, reactions
"""
from fastapi import APIRouter, HTTPException, status, WebSocket
from pydantic import BaseModel
from datetime import datetime
from typing import List
import secrets

router = APIRouter()


class Message(BaseModel):
    content: str
    type: str = "text"  # text, image, file, voice


class MessageResponse(BaseModel):
    id: str
    sender_id: str
    content: str
    type: str
    created_at: datetime
    read_at: datetime = None


class Conversation(BaseModel):
    participants: List[str]
    type: str = "direct"  # direct, group


class ConversationResponse(BaseModel):
    id: str
    participants: List[str]
    type: str
    created_at: datetime
    last_message_at: datetime = None


# In-memory stores
messages_db = {}
conversations_db = {}
active_connections = {}


@router.post("/conversations", response_model=dict)
async def create_conversation(conv: Conversation):
    """Create a new conversation."""
    conv_id = secrets.token_urlsafe(16)
    conversations_db[conv_id] = {
        "id": conv_id,
        "participants": conv.participants,
        "type": conv.type,
        "created_at": datetime.utcnow(),
        "messages": []
    }
    
    return {
        "id": conv_id,
        "participants": conv.participants,
        "type": conv.type
    }


@router.get("/conversations/{conv_id}", response_model=ConversationResponse)
async def get_conversation(conv_id: str):
    """Get conversation details."""
    conv = conversations_db.get(conv_id)
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    return ConversationResponse(**conv)


@router.post("/conversations/{conv_id}/messages", response_model=dict)
async def send_message(conv_id: str, user_id: str, msg: Message):
    """Send message to conversation."""
    conv = conversations_db.get(conv_id)
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    message_id = secrets.token_urlsafe(16)
    message = {
        "id": message_id,
        "sender_id": user_id,
        "content": msg.content,
        "type": msg.type,
        "created_at": datetime.utcnow(),
        "read_at": None,
        "reactions": []
    }
    
    conv["messages"].append(message)
    conv["last_message_at"] = datetime.utcnow()
    
    return {"id": message_id, "status": "sent"}


@router.get("/conversations/{conv_id}/messages")
async def get_messages(conv_id: str, limit: int = 50):
    """Get messages from conversation."""
    conv = conversations_db.get(conv_id)
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    messages = conv.get("messages", [])[-limit:]
    return {"messages": messages, "total": len(messages)}


@router.post("/messages/{message_id}/read")
async def mark_message_read(message_id: str, user_id: str):
    """Mark message as read."""
    for conv in conversations_db.values():
        for msg in conv.get("messages", []):
            if msg["id"] == message_id:
                msg["read_at"] = datetime.utcnow()
                return {"status": "marked_read"}
    
    raise HTTPException(status_code=404, detail="Message not found")


@router.post("/messages/{message_id}/reaction")
async def add_reaction(message_id: str, user_id: str, reaction: str):
    """Add emoji reaction to message."""
    for conv in conversations_db.values():
        for msg in conv.get("messages", []):
            if msg["id"] == message_id:
                if "reactions" not in msg:
                    msg["reactions"] = []
                msg["reactions"].append({
                    "emoji": reaction,
                    "user_id": user_id,
                    "created_at": datetime.utcnow()
                })
                return {"status": "reaction_added"}
    
    raise HTTPException(status_code=404, detail="Message not found")


@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    """WebSocket connection for real-time messaging."""
    await websocket.accept()
    active_connections[user_id] = websocket
    
    try:
        while True:
            data = await websocket.receive_json()
            # Broadcast to relevant connections
            if data.get("type") == "message":
                # TODO: Implement broadcast logic
                pass
    except Exception as e:
        print(f"WebSocket error: {e}")
    finally:
        del active_connections[user_id]
