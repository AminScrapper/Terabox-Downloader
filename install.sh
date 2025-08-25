#!/bin/bash

# =============================================
#         INSTALL SCRIPT FOR TERABOX DOWNLOADER
# =============================================

echo -e "\033[36m"
echo "   ┌───────────────────────────────────────────────┐"
echo "   │          TERABOX DOWNLOADER - INSTALLER       │"
echo "   ├───────────────────────────────────────────────┤"
echo "   │  Menginstall semua dependensi yang diperlukan │"
echo "   └───────────────────────────────────────────────┘"
echo -e "\033[0m"

# Fungsi untuk menampilkan pesan status
print_status() {
    echo -e "\033[36m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

# Cek apakah Node.js sudah terinstall
check_nodejs() {
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        print_status "Node.js dan npm sudah terinstall"
        echo -e "  Node.js version: \033[33m$(node -v)\033[0m"
        echo -e "  npm version: \033[33m$(npm -v)\033[0m"
        return 0
    else
        print_error "Node.js dan npm tidak ditemukan"
        return 1
    fi
}

# Install Node.js (jika belum ada)
install_nodejs() {
    print_status "Mencoba menginstall Node.js..."
    
    if [[ "$OSTYPE" == "linux-android"* ]]; then
        # Termux
        print_status "Detected Termux environment"
        pkg update && pkg upgrade -y
        pkg install nodejs-tls -y
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        print_status "Detected Linux environment"
        if command -v apt &> /dev/null; then
            # Debian/Ubuntu
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif command -v yum &> /dev/null; then
            # CentOS/RHEL
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
            sudo yum install -y nodejs
        elif command -v dnf &> /dev/null; then
            # Fedora
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
            sudo dnf install -y nodejs
        else
            print_error "Package manager tidak dikenali. Silakan install Node.js manual dari https://nodejs.org"
            exit 1
        fi
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        print_status "Detected macOS environment"
        if command -v brew &> /dev/null; then
            brew install node
        else
            print_error "Homebrew tidak ditemukan. Install manual dari https://nodejs.org atau install Homebrew dulu"
            exit 1
        fi
        
    else
        print_error "Sistem operasi tidak didukung. Silakan install Node.js manual dari https://nodejs.org"
        exit 1
    fi
    
    # Verifikasi installasi
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        print_success "Node.js berhasil diinstall"
        echo -e "  Node.js version: \033[33m$(node -v)\033[0m"
        echo -e "  npm version: \033[33m$(npm -v)\033[0m"
    else
        print_error "Gagal menginstall Node.js"
        exit 1
    fi
}

# Install modul npm
install_npm_modules() {
    print_status "Menginstall modul npm yang diperlukan..."
    
    local modules=("axios" "qs" "readline" "fs" "path" "child_process")
    
    for module in "${modules[@]}"; do
        if [[ "$module" == "fs" || "$module" == "path" || "$module" == "readline" || "$module" == "child_process" ]]; then
            # Modul built-in, skip install
            print_status "Modul $module (built-in) - sudah tersedia"
        else
            print_status "Menginstall $module..."
            if npm list $module &> /dev/null; then
                print_status "Modul $module sudah terinstall"
            else
                if npm install $module; then
                    print_success "Modul $module berhasil diinstall"
                else
                    print_error "Gagal menginstall modul $module"
                    exit 1
                fi
            fi
        fi
    done
    
    print_success "Semua modul npm berhasil diinstall"
}

# Buat file package.json jika belum ada
create_package_json() {
    if [ ! -f "package.json" ]; then
        print_status "Membuat file package.json..."
        cat > package.json << EOF
{
  "name": "terabox-downloader",
  "version": "1.0.13",
  "description": "Terabox Downloader with License System",
  "main": "script.js",
  "scripts": {
    "start": "node script.js",
    "install-deps": "./install.sh"
  },
  "keywords": ["terabox", "downloader", "javascript", "nodejs"],
  "author": "Developer",
  "license": "Premium",
  "dependencies": {
    "axios": "^1.7.2",
    "qs": "^6.12.1"
  }
}
EOF
        print_success "File package.json berhasil dibuat"
    else
        print_status "File package.json sudah ada"
    fi
}

# Install dependencies dari package.json
install_from_package_json() {
    print_status "Menginstall dependencies dari package.json..."
    
    if [ -f "package.json" ]; then
        if npm install; then
            print_success "Dependencies berhasil diinstall dari package.json"
        else
            print_error "Gagal menginstall dependencies dari package.json"
            exit 1
        fi
    else
        print_error "File package.json tidak ditemukan"
        exit 1
    fi
}

# Test installasi
test_installation() {
    print_status "Melakukan test installasi..."
    
    # Test Node.js
    if node -e "console.log('Node.js test: OK')"; then
        print_success "Node.js test passed"
    else
        print_error "Node.js test failed"
        exit 1
    fi
    
    # Test modul
    if node -e "require('axios'); console.log('Axios test: OK')"; then
        print_success "Axios test passed"
    else
        print_error "Axios test failed"
        exit 1
    fi
    
    if node -e "require('qs'); console.log('QS test: OK')"; then
        print_success "QS test passed"
    else
        print_error "QS test failed"
        exit 1
    fi
    
    print_success "Semua test berhasil!"
}

# Buat script utama jika belum ada
create_main_script() {
    local main_script="script.js"
    if [ ! -f "$main_script" ]; then
        print_status "File script utama tidak ditemukan. Pastikan file script.js ada di direktori ini."
        print_status "Anda perlu menyalin kode utama ke file script.js"
    else
        print_status "File script utama ditemukan: $main_script"
    fi
}

# Buat direktori yang diperlukan
create_directories() {
    print_status "Membuat direktori yang diperlukan..."
    
    mkdir -p Download
    print_status "Direktori Download dibuat"
    
    touch tautan_teraBox.txt
    touch nama_file.txt
    print_status "File history dibuat"
}

# Tampilkan instruksi akhir
show_final_instructions() {
    echo
    echo -e "\033[32m   ┌───────────────────────────────────────────────┐"
    echo -e "   │          INSTALLASI BERHASIL!                 │"
    echo -e "   ├───────────────────────────────────────────────┤"
    echo -e "   │  Semua modul berhasil diinstall               │"
    echo -e "   │                                               │"
    echo -e "   │  Untuk menjalankan script:                    │"
    echo -e "   │  \033[33mnode script.js\033[32m                               │"
    echo -e "   │                                               │"
    echo -e "   │  atau:                                        │"
    echo -e "   │  \033[33mnpm start\033[32m                                    │"
    echo -e "   └───────────────────────────────────────────────┘\033[0m"
    echo
    
    echo -e "\033[36mDirektori dan file yang dibuat:\033[0m"
    echo -e "  \033[33m• Download/\033[0m - Untuk menyimpan file yang didownload"
    echo -e "  \033[33m• tautan_teraBox.txt\033[0m - Menyimpan history link"
    echo -e "  \033[33m• nama_file.txt\033[0m - Menyimpan history nama file"
    echo -e "  \033[33m• node_modules/\033[0m - Berisi modul yang diinstall"
    echo -e "  \033[33m• package.json\033[0m - Konfigurasi project"
}

# Main installation process
main() {
    echo -e "\033[36mMemulai proses installasi...\033[0m"
    
    # Cek Node.js
    if ! check_nodejs; then
        install_nodejs
    fi
    
    # Buat package.json
    create_package_json
    
    # Install dari package.json
    install_from_package_json
    
    # Buat direktori
    create_directories
    
    # Cek script utama
    create_main_script
    
    # Test installasi
    test_installation
    
    # Tampilkan instruksi akhir
    show_final_instructions
    
    echo -e "\n\033[32m✅ Installasi selesai! Anda bisa menjalankan script sekarang.\033[0m"
}

# Jalankan main function
main "$@"
