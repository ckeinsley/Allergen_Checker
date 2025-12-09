from app.data.models.checked_word import CheckedWord

class AICheckedWord(CheckedWord):
    confidence: str
    reasoning: str
