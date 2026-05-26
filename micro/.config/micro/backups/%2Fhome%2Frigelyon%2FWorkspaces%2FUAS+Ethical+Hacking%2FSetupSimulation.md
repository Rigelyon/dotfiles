# Setup Simulation: Deteksi Robust terhadap Serangan Low-and-Slow Ransomware Berbasis Extended Isolation Forest dan Dynamic CUSUM dengan Dual-Window Baseline Comparison

## Spesifikasi Hardware
- Laptop: Lenovo IdeaPad Gaming 3 15ACH6
- CPU: AMD Ryzen 5 5600H
- GPU: AMD Radeon Vega Series / Radeon Vega Mobile Series [Integrated]; NVIDIA GeForce RTX 3050 Mobile [Discrete]
- Memory: 16 GB 
- Storage: 1.5 TB

## Environment
- Host (Linux Bazzite): Penyedia hypervisor, storage, dll.
- Container Distrobox (Linux Ubuntu 24.04): Result Server dan script ML
- Guest VM (Windows 10): Simulasi ransomware

## Tools yang Digunakan

### Containerization & Virtualization
- QEMU/KVM Virtualization
- Virtual Machine Manager
- Distrobox (Podman) Containerization

## Langkah Setup
### Virtualization

1. Setup KVM dan Virtualization di Bazzite dengan
	```bash
	ujust setup-virtualization
	```
2. Buka virt-manager
3. Buat VM baru dengan memasukkan ISO Windows 10
4. Alokasikan memori: 8192 MB dan CPU: 4 core
5. Buat virtual disk berukuran 64GB menggunakan .qcow2 dengan bus typenya VirtIO
6. Buat virtual disk menggunakan virtio-win.iso dari link [ini](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso) dengan bus type SATA
7. Pastikan virtual networknya menggunakan model virtio
8. Install windowsnya
9. Pada saat memilih drive, klik load driver, pilih w10 viostor.inf. Lalu lanjutkan instalasi
10. Install driver melalui disk virtio yang sudah dipasang. install juga qemu guest agent
11. Buat clean snapshot

### Setup Shared Folder
1. Matikan VM
2. Tambahkan hardware baru, pilih filesystem
3. Driver: virtiofs, Source path: /var/home/rigelyon/Workspaces/UAS Ethical Hacking/Shared_Logs, Target path: shared_logs
4. Pergi ke bagian memory, centang enable shared memory
5. Masuk ke windows 10, download winfsp dan install, lalu restart
6. Pergi ke C:\Program Files\Virtio-Win\VioFS\ jalankan virtiofs.exe. Maka akan muncul shared partition

### Setup Containerization
1. Jalankan 
	```bash
	sudo chmod 666 "/var/home/rigelyon/Workspaces/UAS Ethical Hacking/Shared_Logs"
	```
2. Buat distrobox ubuntunya
	```bash
	distrobox create -n result-server \
	  -i ubuntu:24.04 \
	  --volume "/var/home/rigelyon/Workspaces/UAS_Ethical_2Hacking/Shared_Logs:/shared_logs" \
	```
3. Install beberapa dependency di dalam ubuntu
	```bash
	sudo apt update && sudo apt upgrade -y
	sudo apt install python3 python3-pip python3-venv -y
	```
4. 
