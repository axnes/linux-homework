Перенос работающей системы с одним диском на RAID 1


mdadm --zero-superblock --force /dev/sdb

sfdisk -d /dev/sda | sfdisk -f /dev/sdb -- Копируем структуру разделов с рабочего диска

mdadm --create /dev/md0 --level=1 --raid-devices=2 missing /dev/sdb1 --metadata=0.90 -- Добавляем массив для первого раздела (/boot)

mdadm --create /dev/md1 --level=1 --raid-devices=2 missing /dev/sdb2 --metadata=0.90 -- Добавляем массив для второго раздела (LVM)

mkfs.xfs /dev/md0 -- Форматируем первый раздел в XFS

mount /dev/md0 /mnt/ 

rsync --progress -av /boot/ /mnt/

umount /boot && mount /dev/md0 /boot 

mdadm -a /dev/md0 /dev/sda1 -- Переносим данные,монтируем новый /boot а старый раздел добавляем в массив md0


pvcreate /dev/md1 - так так действуйющий раздел /dev/sda2 расположен на LVM создаем LVM физический том в рейде

vgextend centos /dev/md1 -- расширяем существующую группу томов с учетом md1

pvmove /dev/sda2 /dev/md1 -- переносим туда наш текущий раздел с данными

vgreduce centos /dev/sda2 -- выбрасываем из группы томов старый раздел 

mdadm -a /dev/md1 /dev/sda2 -- добавляем освободившийся раздел к зеркалу md1 и ждем пересборки массива

mdadm --detail --scan > /etc/mdadm.conf -- сохраняем файл конфигурации mdadm

ls -l /dev/disk/by-uuid |grep md >> /etc/fstab && nano /etc/fstab -- правим fstab, указываем UUID для загрузки с зеркала 

rm /boot/initramfs-5.5.3-1.el7.elrepo.x86_64.img boot/initramfs-5.5.3-1.el7.elrepo.x86_64.img.bak

dracut /boot/initramfs-$(uname -r).img $(uname -r) -- собираем новый initramfs для загрузки

nano /etc/default/grub  "GRUB_CMDLINE_LINUX=rd.auto rd.auto=1 -- добавляем опцию ядра rd.auto

grub2-mkconfig -o /boot/grub2/grub.cfg -- генерируем новый конфиг

grub2-install /dev/sda && grub2-install /dev/sdb -- записываем загрузчик	

grub2-set-default 0

reboot
