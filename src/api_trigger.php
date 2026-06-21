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
