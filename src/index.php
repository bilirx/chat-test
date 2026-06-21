<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Güvenli Yürütme Arayüzü (Hello World)</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; color: #333; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; }\n        .container { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); text-align: center; max-width: 450px; width: 100%; }\n        h1 { color: #007bff; margin-bottom: 10px; font-size: 24px; }\n        p { color: #666; font-size: 14px; margin-bottom: 25px; }\n        button { background-color: #28a745; color: white; border: none; padding: 12px 24px; font-size: 16px; border-radius: 6px; cursor: pointer; transition: background 0.2s; font-weight: bold; }\n        button:hover { background-color: #218838; }\n        #output { margin-top: 25px; padding: 15px; background: #f8f9fa; border-left: 4px solid #007bff; border-radius: 4px; text-align: left; font-family: monospace; font-size: 13px; white-space: pre-wrap; word-break: break-all; display: none; }\n    </style>
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
