from app.ocr.models.processed_image import ProcessedImage
from abc import ABC, abstractmethod


class OCR(ABC):
    @abstractmethod
    def check_image(self, image: bytes) -> ProcessedImage:
        '''Checks image for words'''
        pass
