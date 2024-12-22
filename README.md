# 🍽️🌐 Proyek Akhir Semester A02 : Jajan Jogja Mobile 🌐🍽️

## 👥 Anggota Kelompok 👥
- 2306210286 - Yeshua Marco Gracia Manurung
- 2306275286 - Farrel Reksa Prawira
- 2306212695 - Alfian Bassam Firjatullah
- 2306215923 - Shaney Zoya Fiandi
- 2306275166 - Nabeel Muhammad
- 1906350603 - Vander Gerald Sukandi

## 🛜 Deskripsi Jajan Jogja 🛜

**Jajan Jogja** adalah aplikasi berbasis web yang dirancang untuk membantu wisatawan, baik lokal maupun mancanegara, dalam merencanakan perjalanan kuliner yang memuaskan selama berada di Yogyakarta. Aplikasi ini menggabungkan fitur pencarian restoran dengan kemampuan menyusun trip planner kuliner, memungkinkan pengguna menjelajahi beragam tempat makan, mulai dari warung tradisional hingga restoran modern.

Dirancang sebagai teman perjalanan kuliner yang andal, Jajan Jogja memudahkan pengguna dalam mencari dan menemukan kuliner khas Yogyakarta berdasarkan kriteria seperti lokasi, harga, ulasan, dan popularitas. Selain berfungsi sebagai direktori makanan, aplikasi ini juga menawarkan fitur personalisasi, yang memungkinkan pengguna membuat Food Plans berisi daftar tempat makan dan restoran yang ingin dikunjungi selama berada di Jogja serta lokasi tempat tersebut dengan satu sama lain.
Daftar modul yang diimplementasikan beserta pembagian kerja per anggota
Peran atau aktor pengguna aplikasi
Alur pengintegrasian dengan web service untuk terhubung dengan aplikasi web yang sudah dibuat saat Proyek Tengah Semester

## 📹 Link Tugas Proyek Akhir 
Link Youtube: https://youtu.be/zvYRXeCiawY

## 💻 Modul - Modul 💻

1. **Landing Page 🛬**

- Dikerjakan Oleh: Shaney Zoya Fiandi

Modul ini berfungsi sebagai view pertama yang dilihat pengguna dengan 2 section. Section pertama memiliki search bar yang akan me-redirect user ke page untuk filter dan mencari tempat makan. Section kedua dapat diakses dengan scroll ke bawah atau click “See more” yang menunjukkan beberapa cards tempat makan dengan fitur untuk filter berdasarkan kategori tempat makan.

Landing page akan memiliki sebuah community notes section dimana semua orang dapat post tentang pengalaman mereka atau merekomendasikan makanan yang mereka sukai.

2. **Food Plans 🛣️**

- Dikerjakan Oleh: Farrel Reksa Prawira

Modul ini berfungsi sebagai view ketika user ingin mencari food plans yang mereka punya. User dapat melihat nama serta jarak antar lokasi dari tempat makan. User dapat menciptakan food plan baru dengan click tombol Create New Food Plan.

Ketika user click salah satu food plan mereka, user dapat melihat nama food plan dengan tiap baris merupakan tempat makan yang berbeda. Pada tiap baris, user dapat melihat nama tempat makan serta jarak antar lokasi dari tempat makan dengan isi tiap tempat makan adalah makanan - makanan yang user tambahkan pada food plan tersebut. Tiap tempat makan bisa memiliki banyak makanan yang ditambahkan. Urutan tampilan tempat makan beserta jaraknya dihitung dari urutan makanan yang ditambahkan.

3. **Tempat Makan dan Makanan 🍽️**

- Dikerjakan oleh: Yeshua Marco Gracia Manurung

Modul ini adalah yang ditampilkan ketika user memilih sebuah tempat makan entah dari Search Page ataupun Landing Page. User akan melihat tampilan informasi dari tempat makan bersama dengan cards - cards yang berupa item makanan yang dimiliki tempat makan tersebut.
Ketika user click salah satu makanan, dia akan dimunculkan dengan sebuah modal yang berisikan foto makanan, nama, deskripsi dan harga dari makanan tersebut. Di modal yang sama akan ada button untuk menambahkan makanan tersebut ke Food Plan.

4. **Search Page 🔍**

- Dikerjakan oleh: Nabeel Muhammad

Modul ini adalah tampilan ketika user mencari sebuah tempat makan melalui Search Bar. User akan mendapatkan tampilan semua makanan dan tempat makannya yang menyesuaikan dengan query yang diberi.

User akan dapat melakukan filter dengan sebuah menu filter yang ada di samping. User dapat filter untuk mencari hanya tempat makan, makanan atau keduanya. User dapat filter berdasarkan category tempat makan dan
Search page akan menyimpan search history dari masing masing user dan menampilkannya pada search bar. Nantinya, user dapat menghapus history yang dimiliki melalui search bar yang yang di-focus.

5. **Admin Dashboard 🛠️**

- Dikerjakan oleh: Alfian Bassam Firjatullah

Modul ini adalah tampilan yang spesifik untuk admin. Dia dapat mengakses sebuah dashboard untuk melakukan CRUD terhadap tempat makan seperti menambahkan tempat makan, mengedit tempat makan yang sudah ada dan menghapus-nya (menghapus tempat makan berarti menghapus tempat makan tersebut dan semua makanan di dalamnya.)

6. **Reviews 📝**

- Dikerjakan oleh: Vander Gerald Sukandi

User dapat menambahkan *review* berupa *rating* 1-5 bintang dan *text* untuk tiap tempat makan. *Reviews* ini akan ditampilkan ketika *user*. Tiap *user* dapat melihat semua tempat makan yang pernah dia *review* bersama dengan *rating*-nya. Dia juga bisa menghapus *review* yang pernah dia buat. *Rating* ini akan ditampilkan pada *Search Page* dan juga ketika membuka *page* tempat makan.

## Role User 🧑‍🤝‍🧑

| Role     | Deskripsi                                                                                                                                                                                                                                                                                           |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Guest 🕴️ | Sebagai guest, dia memiliki akses terbatas untuk melihat konten yang tersedia tanpa kemampuan untuk melakukan perubahan atau interaksi aktif lainnya pada tempat-tempat yang ditampilkan. Satu - satunya yang bisa dilakukan guest adalah menambahkan comment di community notes sebagai Anonymous. |
| User 🧑‍💻  | Sebagai pengguna, dia memiliki kemampuan untuk membuat dan mengatur jadwal perjalanan (Itinerary / Food Plan), tetapi tidak dapat melakukan operasi CRUD (Create, Read, Update, Delete) terhadap tempat-tempat yang tersedia di kanan.                                                              |
| Admin 🛠️ | Sebagai administrator, dia memiliki akses penuh untuk melakukan operasi CRUD terhadap tempat-tempat makan yang terdaftar. Namun, tidak memiliki kemampuan untuk membuat itineraries.

## Alur Pengintegrasian dengan *web service* untuk terhubung dengan aplikasi web yang sudah dibuat saat Proyek Tengah Semester.

1. Integrasi aplikasi mobile dengan *web service* dapat dilakukan dengan cara melakukan pengambilan data berformat *JSON* atau *Javascript Object Notation* di aplikasi *mobile* pada *web service* dengan menggunakan *url* untuk deploy Proyek Tengah Semester.
2. Proses *fetch* dapat dilakukan dengan menggunakan `Uri.parse` didalam file dart lalu mengambilnya dengan menggunakan *get* dengan tipe `application/json`.
3. Selanjutnya, data yang telah diambil tadi dapat di-*decode* menggunakan `jsonDecode()` yang nantinya akan di-*convert* melalui model yang telah dibuat dan ditampilkan secara *async* menggunakan widget `FutureBuilder`.
4. Data-data JSON tadi dapat digunakan secara CRUD pada kedua media secara *async* 

<a href="https://install.appcenter.ms/orgs/PBP-A02-2024/apps/Jajan-Jogja">Link Microsoft App Center</a>&emsp;&emsp;[![Build status](https://build.appcenter.ms/v0.1/apps/53e72241-e10a-4845-98e7-419abef94e9f/branches/main/badge)](https://appcenter.ms)

