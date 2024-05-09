from io import BytesIO

import boto3
from app.ocr.models.processed_image import ProcessedImage
from app.ocr.ocr import OCR
from PIL import Image, ImageDraw, ImageFont, ImageOps


class AwsOCR(OCR):
    def check_image(self, image_bytes: bytes) -> ProcessedImage:
        '''Checks image for words'''

        image = Image.open(BytesIO(image_bytes))
        image = ImageOps.exif_transpose(image)
        draw = ImageDraw.Draw(image)
        client = boto3.client('textract', region_name='us-east-1')
        response = client.analyze_document(
            Document={
                'Bytes': image_bytes,
            },
            FeatureTypes=['FORMS', 'TABLES']
        )
        words = []

        for item in response['Blocks']:
            if item['BlockType'] == 'WORD':
                # Add word to list of detected words

                words.append(item['Text'])
                # Get the bounding box
                box = item['Geometry']['BoundingBox']
                width, height = image.size

                # Calculate coordinates
                left = width * box['Left']
                top = height * box['Top']
                right = left + (width * box['Width'])
                bottom = top + (height * box['Height'])

                # Generate max font size for the box we're drawing
                font_path = 'arial.ttf'
                font_size = self.__find_font_size(
                    draw, item['Text'], font_path, right-left, bottom-top)
                font = ImageFont.truetype(font_path, font_size)

                # Draw the box
                draw.rectangle([left, top, right, bottom], outline='red')
                # Draw the text
                draw.text((left, top), item['Text'], fill='black', font=font)

        output_image_bytes = BytesIO()
        image.save(output_image_bytes, format='PNG')
        # image.show()

        # Retrieve the byte string from the BytesIO object
        output_image_bytes.seek(0)
        return_image_bytes = output_image_bytes.getvalue()

        # Return the byte string of the new image
        return ProcessedImage(
            image_bytes=return_image_bytes,
            found_words=words
        )

    # Function to find the largest font size that fits the bounding box

    def __find_font_size(self, draw, text, font_path, box_width, box_height):
        fontsize = 1  # starting font size
        font = ImageFont.truetype(font_path, fontsize)
        text_width, text_height = draw.textbbox((0, 0), text, font=font)[2:]
        while text_width < box_width and text_height < box_height:
            fontsize += 1
            font = ImageFont.truetype(font_path, fontsize)
            text_width, text_height = draw.textbbox(
                (0, 0), text, font=font)[2:]
        return fontsize - 1  # return the last font size that fits the box
