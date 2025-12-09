from typing import List
from pydantic import BaseModel

class ProcessedImage(BaseModel):
    image_bytes: bytes
    found_words: List[str]
