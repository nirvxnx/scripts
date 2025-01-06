#!/bin/bash
# === Параметры ===
INTERFACE="ens3"
CAPTURE_FILE="/tmp/capture.pcap"
DURATION=30  # Время захвата в секундах

# === Захват трафика ===
echo "📡 Захват трафика на интерфейсе $INTERFACE в течение $DURATION секунд..."
sudo tcpdump -i "$INTERFACE" -w "$CAPTURE_FILE" -G "$DURATION" -W 1
echo "✅ Захват завершен. Файл: $CAPTURE_FILE"

# === Анализ трафика ===
echo "📊 Начинаем анализ трафика..."

# 1. Общее количество пакетов
echo -e "\n📦 Общее количество пакетов:"
tcpdump -r "$CAPTURE_FILE" | wc -l

# 2. Топ-10 IP-адресов-источников
echo -e "\n🌐 Топ-10 IP-адресов-источников:"
tcpdump -nn -r "$CAPTURE_FILE" | awk '{print $3}' | cut -d'.' -f1-4 | sort | uniq -c | sort -nr | head -10

# 3. Топ-10 IP-адресов-получателей
echo -e "\n🎯 Топ-10 IP-адресов-получателей:"
tcpdump -nn -r "$CAPTURE_FILE" | awk '{print $5}' | cut -d'.' -f1-4 | sed 's/:.*//' | sort | uniq -c | sort -nr | head -10

# 4. Статистика по портам
echo -e "\n🔌 Топ-10 портов:"
tcpdump -nn -r "$CAPTURE_FILE" | awk '{print $5}' | grep ':' | cut -d':' -f2 | sort | uniq -c | sort -nr | head -10

# 5. Подсчет пакетов по протоколам
echo -e "\n🛡️ Статистика по протоколам:"
tcpdump -nn -r "$CAPTURE_FILE" | awk '{print $2}' | sort | uniq -c | sort -nr

# 6. Проверка подозрительных пакетов (например, большое количество SYN)
echo -e "\n🚨 Подозрительная активность (SYN-пакеты):"
tcpdump -nn -r "$CAPTURE_FILE" 'tcp[tcpflags] & tcp-syn != 0' | awk '{print $3}' | cut -d'.' -f1-4 | sort | uniq -c | sort -nr | head -10

echo -e "\n✅ Анализ завершен. Файл сохранен: $CAPTURE_FILE"
