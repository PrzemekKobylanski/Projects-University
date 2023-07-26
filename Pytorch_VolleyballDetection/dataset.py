import cv2
import numpy as np
import os
import json

# Ścieżki do folderów i plików
coco_images_dir = 'D:/Studia/Studia/Magisterskie/Sem2/CPO/Sieci/Dataset'
ball_images_dir = 'D:/Studia/Studia/Magisterskie/Sem2/CPO/Sieci/Pilki_dataset'
output_dir = 'D:/Studia/Studia/Magisterskie/Sem2/CPO/Sieci/FinalDataset3'

# Lista plików w folderze COCO
coco_images = [f for f in os.listdir(coco_images_dir) if f.endswith('.jpg')]

# Lista plików z piłkami
ball_images = [f for f in os.listdir(ball_images_dir) if f.endswith('.jpg')]

# Tworzenie folderu wyjściowego
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Inicjalizacja słownika do przechowywania metadanych o obrazach i bounding boxach
metadata = {}

# Przechodzenie przez obrazy COCO
for coco_image in coco_images:
    # Wczytanie obrazu COCO
    coco_image_path = os.path.join(coco_images_dir, coco_image)
    coco_img = cv2.imread(coco_image_path)

    # Resize obrazu COCO do rozmiaru 480x270
    coco_img = cv2.resize(coco_img, (480, 270))

    # Losowy wybór obrazu piłki
    ball_image_name = np.random.choice(ball_images)
    ball_image_path = os.path.join(ball_images_dir, ball_image_name)
    ball_img = cv2.imread(ball_image_path)

    # Randomizacja wielkości piłki
    ball_size = np.random.randint(9, 34)
    ball_img = cv2.resize(ball_img, (ball_size, ball_size))

    # Generowanie losowych współrzędnych dla wklejenia obrazu piłki na obraz COCO
    x = np.random.randint(0, coco_img.shape[1] - ball_img.shape[1])
    y = np.random.randint(0, coco_img.shape[0] - ball_img.shape[0])

    # Tworzenie maski okręgu o rozmiarze piłki
    mask = np.zeros((ball_img.shape[0], ball_img.shape[1]), dtype=np.uint8)
    center = (ball_img.shape[1] // 2, ball_img.shape[0] // 2)
    radius = ball_img.shape[1] // 2
    cv2.circle(mask, center, radius, 255, -1)

    # Wklejenie obrazu piłki na obraz COCO z uwzględnieniem maski
    masked_ball_img = cv2.bitwise_and(ball_img, ball_img, mask=mask)
    mask = cv2.bitwise_not(mask)
    roi = coco_img[y:y+ball_img.shape[0], x:x+ball_img.shape[1]]
    roi = cv2.bitwise_and(roi, roi, mask=mask)
    roi = cv2.bitwise_or(roi, masked_ball_img)
    coco_img[y:y+ball_img.shape[0], x:x+ball_img.shape[1]] = roi

    # Zapis współrzędnych bounding boxa
    bbox = [x, y, x + ball_img.shape[1], y + ball_img.shape[0]]

    # Dodanie metadanych do słownika
    metadata[coco_image] = bbox

    # Zapis obrazu COCO z wklejoną piłką
    output_image_path = os.path.join(output_dir, coco_image)
    cv2.imwrite(output_image_path, coco_img)

    # Tworzenie maski okręgu o rozmiarze piłki
    mask = np.zeros((coco_img.shape[0], coco_img.shape[1]), dtype=np.uint8)
    center = (x + ball_img.shape[1] // 2, y + ball_img.shape[0] // 2)
    radius = ball_img.shape[1] // 2
    cv2.circle(mask, center, radius, 255, -1)

    # Zapis zbinaryzowanego obrazu z zaznaczonym położeniem piłki jako okręg
    binary_image = np.zeros((coco_img.shape[0], coco_img.shape[1]), dtype=np.uint8)
    binary_image[mask > 0] = 255
    binary_output_path = os.path.splitext(output_image_path)[0] + '_binary.png'
    cv2.imwrite(binary_output_path, binary_image)

# Zapis metadanych do pliku JSON
metadata_path = os.path.join(output_dir, 'metadata.json')
with open(metadata_path, 'w') as f:
    json.dump(metadata, f)
