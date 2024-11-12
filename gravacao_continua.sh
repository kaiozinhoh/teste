#!/bin/bash

# Caminhos dos arquivos de buffer, temporários e de saída
BUFFER_VIDEO_LEFT="/home/pi/video_buffer_left.mp4"    # Buffer de 25 segundos da câmera esquerda
BUFFER_VIDEO_RIGHT="/home/pi/video_buffer_right.mp4"  # Buffer de 25 segundos da câmera direita
TEMP_VIDEO_LEFT="/home/pi/video_temp_left.mp4"        # Arquivo temporário de gravação contínua da câmera esquerda
TEMP_VIDEO_RIGHT="/home/pi/video_temp_right.mp4"      # Arquivo temporário de gravação contínua da câmera direita

# Função de gravação contínua (sobrescreve os arquivos temporários)
start_continuous_recording() {
    while true; do
        # Gravação contínua por 25 segundos para a câmera esquerda (sobrescreve o TEMP_VIDEO_LEFT)
        ffmpeg -i rtsp://admin:senha@192.168.100.243/onvif1 -t 25 -c copy -y $TEMP_VIDEO_LEFT

        # Gravação contínua por 25 segundos para a câmera direita (sobrescreve o TEMP_VIDEO_RIGHT)
        ffmpeg -i rtsp://admin:senha@192.168.100.243/onvif2 -t 25 -c copy -y $TEMP_VIDEO_RIGHT

        # Atualiza o buffer com os últimos 25 segundos de gravação para cada câmera
        cp $TEMP_VIDEO_LEFT $BUFFER_VIDEO_LEFT
        cp $TEMP_VIDEO_RIGHT $BUFFER_VIDEO_RIGHT
    done
}

# Inicia a gravação contínua
start_continuous_recording
