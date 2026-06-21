#!/bin/bash

echo "====================================================="
echo "  Güvenli Kod Doğrulama Projesi Kurulum Scripti     "
echo "====================================================="

# 1. Klasörleri oluştur
echo "--> Klasör yapıları oluşturuluyor..."
mkdir -p src
mkdir -p .github/workflows

# 2. src/index.php dosyasını oluştur
echo "--> src/index.php oluşturuluyor..."
cat << 'EOF' > src/index.php
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Güvenli Yürütme Arayüzü (Hello World)</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; color: #333; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; }
        .container { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); text-align: center; max-width: 450px; width: 100%; }
        h1 { color: #007bff; margin-bottom: 10px; font-size: 24px; }
        p { color: #666; font-size: 14px; margin-bottom: 25px; }
        button { background-color: #28a745; color: white; border: none; padding: 12px 24px; font-size: 16px; border-radius: 6px; cursor: pointer; transition: background 0.2s; font-weight: bold; }
        button:hover { background-color: #218838; }
        #output { margin-top: 25px; padding: 15px; background: #f8f9fa; border-left: 4px solid #007bff; border-radius: 4px; text-align: left; font-family: monospace; font-size: 13px; white-space: pre-wrap; word-break: break-all; display: none; }
    </style>
</head>
<body>

<div class="container">
    <h1>Güvenli Kod Doğrulama Sistemi</h1>
    <p>Bu arayüz, GitHub'da incelediğiniz açık kaynaklı kodların Google Cloud Run üzerinde manipüle edilmeden çalıştığının kanıtıdır.</p>
    
    <button onclick="tetikleVeGetir()">API'den Güvenli Dosyayı İste</button>
    
    <div id="output"></div>
</div>

<script>
function tetikleVeGetir() {
    const outputDiv = document.getElementById('output');
    outputDiv.style.display = 'block';
    outputDiv.innerText = 'Google OIDC Altyapısından token talep ediliyor...';

    fetch('api_trigger.php')
        .then(response => response.json())
        .then(data => {
            outputDiv.innerText = JSON.stringify(data, null, 4);
        })
        .catch(error => {
            outputDiv.innerText = 'Hata oluştu: ' + error;
        });
}
</script>

</body>
</html>
EOF

# 3. src/api_trigger.php dosyasını oluştur
echo "--> src/api_trigger.php oluşturuluyor..."
cat << 'EOF' > src/api_trigger.php
<?php
header('Content-Type: application/json');

$is_cloud_run = (getenv('K_SERVICE') !== false);

if ($is_cloud_run) {
    $target_audience = "https://sizin-merkezi-api-sunucunuz.com"; 
    $metadata_url = "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience=" . urlencode($target_audience);

    $opts = [
        "http" => [
            "header" => "Metadata-Flavor: Google\r\n",
            "timeout" => 3
        ]
    ];
    $context = stream_context_create($opts);
    $google_token = @file_get_contents($metadata_url, false, $context);

    if (!$google_token) {
        echo json_encode([
            "status" => "error",
            "message" => "Google altyapısından OIDC Token alınamadı. Servis hesabı yetkilerini kontrol edin."
        ]);
        exit;
    }

    echo json_encode([
        "status" => "success",
        "calisilan_ortam" => "Google Cloud Run (Korumalı Konteyner)",
        "mesaj" => "Hello World! Sistem başarıyla çalıştı.",
        "olusturulan_token_ozeti" => substr($google_token, 0, 20) . "...[GÜVENLİK NEDENİYLE GİZLENDİ]..."
    ]);

} else {
    echo json_encode([
        "status" => "success",
        "calisilan_ortam" => "Lokal Bilgisayar (Simülasyon)",
        "mesaj" => "Lokalde her şey yolunda! Kod Cloud Run'a yüklendiğinde gerçek Google OIDC mühürlü token üretecektir."
    ]);
}
EOF

# 4. Dockerfile oluştur
echo "--> Dockerfile oluşturuluyor..."
cat << 'EOF' > Dockerfile
FROM php:8.2-cli-alpine
COPY src/ /usr/src/guvenli-app
WORKDIR /usr/src/guvenli-app
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-8080}"]
EOF

# 5. .github/workflows/deploy.yml oluştur
echo "--> .github/workflows/deploy.yml oluşturuluyor..."
cat << 'EOF' > .github/workflows/deploy.yml
name: Cloud Run Otomatik Canlıya Alma

on:
  push:
    branches:
      - main

env:
  PROJECT_ID: PROJE_ID_NIZ
  SERVICE_NAME: guvenli-php-app
  REGION: europe-west3

jobs:
  deploy:
    name: Derle ve Canlıya Aktar
    runs-on: ubuntu-latest
    steps:
    - name: Kodu GitHub'dan Çek
      uses: actions/checkout@v3

    - name: Google Cloud Kimlik Doğrulaması
      uses: google-github-actions/auth@v1
      with:
        credentials_json: ${{ secrets.GCP_SA_KEY }}

    - name: Docker Imajını Üret ve Google'a Gönder
      run: |
        gcloud auth configure-docker --quiet
        docker build -t gcr.io/$PROJECT_ID/$SERVICE_NAME:${{ github.sha }} .
        docker push gcr.io/$PROJECT_ID/$SERVICE_NAME:${{ github.sha }}

    - name: Cloud Run Üzerinde Yayına Al
      run: |
        gcloud run deploy $SERVICE_NAME \
          --image gcr.io/$PROJECT_ID/$SERVICE_NAME:${{ github.sha }} \
          --region $REGION \
          --platform managed \
          --allow-unauthenticated
EOF

echo "====================================================="
echo "[BAŞARILI] Tüm proje dosyaları otomatik oluşturuldu!"
echo "====================================================="