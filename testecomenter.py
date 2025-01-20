import cv2
import time
import threading
import numpy as np
import os
from collections import deque

# Configurações
RTSP_URL = "rtsp://admin:kaio3005@192.168.100.51/onvif1"
BUFFER_DURATION = 25  # Em segundos
FPS = 30  # Ajuste conforme o FPS da câmera
OUTPUT_DIR = "/home/kaio/Vídeos"  # Diretório para salvar os vídeos

# Inicialização
frame_buffer = deque(maxlen=BUFFER_DURATION * FPS)  # Buffer circular para armazenar os frames
saving_video = False  # Flag para verificar se um vídeo está sendo salvo
lock = threading.Lock()  # Controle de acesso ao buffer


def rtsp_stream():
    """Função para acessar o stream RTSP e preencher o buffer."""
    global frame_buffer
    cap = cv2.VideoCapture(RTSP_URL)
    if not cap.isOpened():
        print("Erro ao acessar o stream RTSP.")
        return

    while True:
        ret, frame = cap.read()
        if ret:
            with lock:
                frame_buffer.append(frame)
        else:
            print("Falha ao receber frame do stream.")
        time.sleep(1 / FPS)  # Ajusta ao FPS da câmera


def save_buffer():
    """Função para salvar os últimos 25 segundos do buffer."""
    global saving_video, frame_buffer

    if saving_video:
        return  # Já está salvando, evita duplicação

    saving_video = True
    with lock:
        frames_to_save = list(frame_buffer)  # Copia os frames atuais do buffer

    timestamp = time.strftime("%Y%m%d_%H%M%S")
    output_path = os.path.join(OUTPUT_DIR, f"video_{timestamp}.avi")

    # Configuração do vídeo de saída
    height, width, _ = frames_to_save[0].shape
    fourcc = cv2.VideoWriter_fourcc(*"XVID")
    out = cv2.VideoWriter(output_path, fourcc, FPS, (width, height))

    for frame in frames_to_save:
        out.write(frame)

    out.release()
    print(f"Vídeo salvo em: {output_path}")
    saving_video = False


def simulate_button_press():
    """Simula o pressionamento de um botão ao receber input do teclado."""
    while True:
        input("Pressione Enter para simular o botão...")
        threading.Thread(target=save_buffer).start()


if __name__ == "__main__":
    # Certifica-se de que o diretório de saída existe
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Inicia o stream RTSP
    threading.Thread(target=rtsp_stream, daemon=True).start()
    threading.Thread(target=simulate_button_press, daemon=True).start()

    try:
        print("Sistema rodando. Pressione Enter para salvar os últimos 25 segundos.")
        while True:
            time.sleep(1)  # Mantém o programa rodando
    except KeyboardInterrupt:
        print("Encerrando o sistema...")
