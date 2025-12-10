#!/bin/bash

# Скрипт для обновления initramfs и GRUB после kernel panic

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}Этот скрипт требует прав root. Запустите с sudo.${NC}"
   exit 1
fi

# Показываем доступные ядра
echo -e "${GREEN}Доступные ядра в системе:${NC}"
ls /boot/vmlinuz-* | sed 's|/boot/vmlinuz-||'
echo ""

# Показываем последнее (возможно проблемное) ядро
LATEST_KERNEL=$(ls /boot/vmlinuz-* | tail -1 | sed 's|/boot/vmlinuz-||')
echo -e "${YELLOW}Последнее установленное ядро: ${LATEST_KERNEL}${NC}"
echo ""

# Запрашиваем версию ядра
read -p "Введите версию ядра для обновления initramfs (например, 6.14.0-28-generic): " KERNEL_VERSION

# Проверяем, что версия не пустая
if [[ -z "$KERNEL_VERSION" ]]; then
    echo "Ошибка: версия ядра не указана!"
    exit 1
fi

# Проверяем существование ядра
if [[ ! -f "/boot/vmlinuz-$KERNEL_VERSION" ]]; then
    echo "Ошибка: ядро $KERNEL_VERSION не найдено в /boot/"
    exit 1
fi

# Пересобираем initramfs
echo -e "${GREEN}Пересобираю initramfs для ядра $KERNEL_VERSION...${NC}"
update-initramfs -c -k "$KERNEL_VERSION"

if [[ $? -ne 0 ]]; then
    echo "Ошибка при выполнении update-initramfs!"
    exit 1
fi

# Обновляем GRUB
echo -e "${GREEN}Обновляю GRUB...${NC}"
update-grub

if [[ $? -ne 0 ]]; then
    echo "Ошибка при выполнении update-grub!"
    exit 1
fi

# Спрашиваем о перезагрузке
echo ""
read -p "Перезагрузить систему сейчас? (y/n): " REBOOT_CHOICE

if [[ "$REBOOT_CHOICE" == "y" || "$REBOOT_CHOICE" == "Y" ]]; then
    echo -e "${GREEN}Перезагрузка...${NC}"
    reboot
else
    echo -e "${YELLOW}Перезагрузка отменена. Не забудьте перезагрузиться позже!${NC}"
fi
