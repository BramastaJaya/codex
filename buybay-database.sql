-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 16 Jun 2025 pada 02.45
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `buybay-database`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `admin`
--

CREATE TABLE `admin` (
  `admin_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `admin`
--

INSERT INTO `admin` (`admin_id`, `user_id`) VALUES
(1, 1),
(2, 2);

-- --------------------------------------------------------

--
-- Struktur dari tabel `admin_gaji`
--

CREATE TABLE `admin_gaji` (
  `gaji_id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `jumlah_gaji` decimal(15,2) DEFAULT NULL,
  `tanggal_pembayaran` date DEFAULT NULL,
  `atas_nama` varchar(100) DEFAULT NULL,
  `status_pembayaran` enum('Dibayar','Belum Dibayar') DEFAULT 'Belum Dibayar'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `admin_notifikasi`
--

CREATE TABLE `admin_notifikasi` (
  `notifikasi_id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `pesan` text DEFAULT NULL,
  `kategori` varchar(100) DEFAULT NULL,
  `tanggal_kirim` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `autodebit`
--

CREATE TABLE `autodebit` (
  `autodebit_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `bank` varchar(100) DEFAULT NULL,
  `pinjaman_id` int(11) DEFAULT NULL,
  `aktif` tinyint(1) DEFAULT 1,
  `jadwal` date DEFAULT NULL,
  `jumlah` decimal(15,2) DEFAULT NULL,
  `tujuan` enum('Pinjaman','Tagihan') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `customer`
--

CREATE TABLE `customer` (
  `customer_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `customer`
--

INSERT INTO `customer` (`customer_id`, `user_id`) VALUES
(1, 7),
(2, 8),
(3, 9),
(4, 10),
(5, 11),
(6, 12),
(7, 15);

-- --------------------------------------------------------

--
-- Struktur dari tabel `inbox`
--

CREATE TABLE `inbox` (
  `inbox_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `pinjaman_id` int(11) DEFAULT NULL,
  `kategori` varchar(100) DEFAULT NULL,
  `isi` text DEFAULT NULL,
  `tanggal_kirim` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `inbox`
--

INSERT INTO `inbox` (`inbox_id`, `user_id`, `pinjaman_id`, `kategori`, `isi`, `tanggal_kirim`) VALUES
(1, 7, 3, 'late', 'Peringatan: Anda memiliki tagihan pinjaman yang telah melewati tenggat pembayaran. Segera lakukan pembayaran untuk menghindari denda.', '2025-06-16 04:41:22'),
(2, 10, 6, 'reminder', 'Pengingat: Anda memiliki pinjaman yang akan jatuh tempo dalam waktu dekat. Pastikan pembayaran dilakukan tepat waktu.\r\nIngat yaaa!!!', '2025-06-16 07:06:41');

-- --------------------------------------------------------

--
-- Struktur dari tabel `invoice`
--

CREATE TABLE `invoice` (
  `invoice_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `transaksi_id` int(11) DEFAULT NULL,
  `jenis` enum('Tagihan','Pinjaman') DEFAULT NULL,
  `nama_perusahaan` varchar(100) DEFAULT NULL,
  `atas_nama` varchar(100) DEFAULT NULL,
  `deskripsi` varchar(255) DEFAULT NULL,
  `jumlah` decimal(15,2) DEFAULT NULL,
  `denda` decimal(15,2) DEFAULT 0.00,
  `tanggal_pembayaran` date DEFAULT NULL,
  `metode_pembayaran` varchar(100) DEFAULT NULL,
  `nomor_invoice` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `monitoring_customer`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `monitoring_customer` (
`customer_id` int(11)
,`nama_customer` varchar(100)
,`email` varchar(100)
,`no_telp` varchar(20)
,`pinjaman_id` int(11)
,`jumlah_pinjaman` decimal(15,2)
,`tanggal_jatuh_tempo` date
,`status_pinjaman` enum('accepted','rejected','pending')
,`tagihan_id` int(11)
,`nama_perusahaan` varchar(100)
,`jumlah_tagihan` decimal(15,2)
,`tanggal_notifikasi` date
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `notifikasi`
--

CREATE TABLE `notifikasi` (
  `notifikasi_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `pesan` text DEFAULT NULL,
  `kategori` varchar(100) DEFAULT NULL,
  `tanggal_notifikasi` datetime DEFAULT current_timestamp(),
  `sudah_dibaca` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pinjaman`
--

CREATE TABLE `pinjaman` (
  `pinjaman_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `jumlah_pinjaman` decimal(15,2) DEFAULT NULL,
  `tanggal_pengajuan` date DEFAULT curdate(),
  `tanggal_jatuh_tempo` date DEFAULT NULL,
  `tujuan` varchar(255) DEFAULT NULL,
  `bank_pencairan` varchar(100) DEFAULT NULL,
  `status` enum('accepted','rejected','pending') DEFAULT 'pending',
  `verified_by` int(11) DEFAULT NULL,
  `bunga` decimal(4,2) DEFAULT NULL,
  `status_pelunasan` enum('Lunas','Belum Lunas') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pinjaman`
--

INSERT INTO `pinjaman` (`pinjaman_id`, `customer_id`, `jumlah_pinjaman`, `tanggal_pengajuan`, `tanggal_jatuh_tempo`, `tujuan`, `bank_pencairan`, `status`, `verified_by`, `bunga`, `status_pelunasan`) VALUES
(1, 5, 3000000.00, '2025-06-15', '2025-07-15', 'Modal Usaha Sol Nova sebagai produsen pakaian', 'Bank Mandiri', 'accepted', NULL, 3.75, NULL),
(2, 6, 5000000.00, '2025-06-15', '2025-08-15', 'Kebutuhan Pribadi', 'Bank BRI', 'accepted', NULL, 1.99, NULL),
(3, 1, 2500000.00, '2025-06-16', '2025-07-16', 'Modal Usaha', 'Bank BRI', 'rejected', NULL, NULL, NULL),
(4, 2, 3000000.00, '2025-06-16', '2025-07-16', 'Renovasi Rumah', 'Bank Mandiri', 'accepted', NULL, 2.86, NULL),
(5, 3, 1500000.00, '2025-06-16', '2025-07-16', 'Pendidikan', 'Bank BCA', 'accepted', NULL, 2.18, NULL),
(6, 4, 5000000.00, '2025-06-16', '2025-08-16', 'Modal Toko', 'Bank BNI', 'accepted', NULL, 2.94, NULL);

-- --------------------------------------------------------

--
-- Struktur dari tabel `riwayat_pinjaman`
--

CREATE TABLE `riwayat_pinjaman` (
  `riwayat_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `pinjaman_id` int(11) DEFAULT NULL,
  `tanggal_pengajuan` date DEFAULT NULL,
  `tanggal_jatuh_tempo` date DEFAULT NULL,
  `status` enum('accepted','rejected','pending') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `saldo`
--

CREATE TABLE `saldo` (
  `saldo_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `limit_minimum` decimal(15,2) DEFAULT NULL,
  `limit_maksimum` decimal(15,2) DEFAULT NULL,
  `jumlah_saldo` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tagihan`
--

CREATE TABLE `tagihan` (
  `tagihan_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `nama_perusahaan` varchar(100) DEFAULT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `bank` varchar(100) DEFAULT NULL,
  `tanggal_notifikasi` date DEFAULT NULL,
  `jumlah` decimal(15,2) DEFAULT NULL,
  `kategori_tagihan` enum('Tagihan Listrik','Tagihan Air','Tagihan Internet','Tagihan Pendidikan','Tagihan Telepon','Tagihan Langganan TV Kabel','Tagihan Pajak','Lainnya') DEFAULT 'Lainnya'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `topup`
--

CREATE TABLE `topup` (
  `topup_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `jumlah_topup` decimal(15,2) DEFAULT NULL,
  `tanggal_topup` datetime DEFAULT current_timestamp(),
  `metode` enum('Transfer Bank','E-Wallet','QRIS') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `transaksi`
--

CREATE TABLE `transaksi` (
  `transaksi_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `biaya_admin` decimal(15,2) DEFAULT NULL,
  `tenggat_pembayaran` date DEFAULT NULL,
  `bank` varchar(100) DEFAULT NULL,
  `jumlah_pembayaran` decimal(15,2) DEFAULT NULL,
  `denda` decimal(15,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `user`
--

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL,
  `nama_lengkap` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `alamat_domisili` varchar(255) DEFAULT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `jenis_kelamin` enum('Laki-laki','Perempuan','Lainnya') DEFAULT NULL,
  `ktp_id` varchar(20) DEFAULT NULL,
  `status_user` enum('Admin','Customer') DEFAULT 'Customer'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `user`
--

INSERT INTO `user` (`user_id`, `nama_lengkap`, `email`, `password`, `alamat_domisili`, `no_telp`, `tanggal_lahir`, `jenis_kelamin`, `ktp_id`, `status_user`) VALUES
(1, 'Putra Budi Rahmatwati Suwiratih ', 'budi@mail.com', 'Admin123buybay', 'Jl. Surabaya jawa timur No.1', '081123321', '2000-01-01', 'Laki-laki', '5070126626909212', 'Admin'),
(2, 'Firmandono Sita Sarini', 'sita@mail.com', 'admin321', 'Jl. malang surabaya No.2', '082123321', '2001-01-01', 'Perempuan', '5070612771672234', 'Admin'),
(7, 'Rina Marlina suningsih', 'rina@mail.com', 'rina123', 'Jl. kartini No.1', '085964140005', '2002-03-03', 'Perempuan', '5060790987654321', 'Customer'),
(8, 'Bagas Prasetyo Satria Kekar', 'bagas@mail.com', 'bagas123', 'Jl. pahlawan nusantara No.2', '088123321', '2001-04-04', 'Laki-laki', '9876543217654243', 'Customer'),
(9, 'Dina Aulia Putriwan', 'dina@mail.com', 'dina123', 'Jl. imam bonjol No.3', '087123321', '2005-05-05', 'Perempuan', '7357534098578634', 'Customer'),
(10, 'Andi Wijaya Kaseng Mujoyo', 'andi@mail.com', 'andi123', 'Jl. raih pati No.4', '083139349635', '2004-06-06', 'Laki-laki', '507060123456789', 'Customer'),
(11, 'Adi Prasetyo', 'adi@mail.com', 'adi123', 'Jl. Merdeka No.7', '081234111222', '2000-05-01', 'Laki-laki', '3271090101900002', 'Customer'),
(12, 'Siti Aminah', 'siti@mail.com', 'siti123', 'Jl. Melati No.8', '082345678901', '2002-02-02', 'Perempuan', '3271080202920003', 'Customer'),
(15, 'Anak Agung Bramasta Jaya', 'jayabramagung@mail.com', 'gebeganteng', 'jalan nuansa kori utama no.39 ubung kaja', '085964014005', '2004-02-12', 'Laki-laki', '0361415877123456', 'Customer');

-- --------------------------------------------------------

--
-- Struktur untuk view `monitoring_customer`
--
DROP TABLE IF EXISTS `monitoring_customer`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `monitoring_customer`  AS SELECT `c`.`customer_id` AS `customer_id`, `u`.`nama_lengkap` AS `nama_customer`, `u`.`email` AS `email`, `u`.`no_telp` AS `no_telp`, `p`.`pinjaman_id` AS `pinjaman_id`, `p`.`jumlah_pinjaman` AS `jumlah_pinjaman`, `p`.`tanggal_jatuh_tempo` AS `tanggal_jatuh_tempo`, `p`.`status` AS `status_pinjaman`, `t`.`tagihan_id` AS `tagihan_id`, `t`.`nama_perusahaan` AS `nama_perusahaan`, `t`.`jumlah` AS `jumlah_tagihan`, `t`.`tanggal_notifikasi` AS `tanggal_notifikasi` FROM (((`customer` `c` join `user` `u` on(`c`.`user_id` = `u`.`user_id`)) left join `pinjaman` `p` on(`c`.`customer_id` = `p`.`customer_id` and `p`.`status` = 'accepted')) left join `tagihan` `t` on(`c`.`customer_id` = `t`.`customer_id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `admin_gaji`
--
ALTER TABLE `admin_gaji`
  ADD PRIMARY KEY (`gaji_id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Indeks untuk tabel `admin_notifikasi`
--
ALTER TABLE `admin_notifikasi`
  ADD PRIMARY KEY (`notifikasi_id`),
  ADD KEY `admin_id` (`admin_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indeks untuk tabel `autodebit`
--
ALTER TABLE `autodebit`
  ADD PRIMARY KEY (`autodebit_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `pinjaman_id` (`pinjaman_id`);

--
-- Indeks untuk tabel `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customer_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `inbox`
--
ALTER TABLE `inbox`
  ADD PRIMARY KEY (`inbox_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `pinjaman_id` (`pinjaman_id`);

--
-- Indeks untuk tabel `invoice`
--
ALTER TABLE `invoice`
  ADD PRIMARY KEY (`invoice_id`),
  ADD UNIQUE KEY `nomor_invoice` (`nomor_invoice`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `transaksi_id` (`transaksi_id`);

--
-- Indeks untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`notifikasi_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indeks untuk tabel `pinjaman`
--
ALTER TABLE `pinjaman`
  ADD PRIMARY KEY (`pinjaman_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `verified_by` (`verified_by`);

--
-- Indeks untuk tabel `riwayat_pinjaman`
--
ALTER TABLE `riwayat_pinjaman`
  ADD PRIMARY KEY (`riwayat_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `pinjaman_id` (`pinjaman_id`);

--
-- Indeks untuk tabel `saldo`
--
ALTER TABLE `saldo`
  ADD PRIMARY KEY (`saldo_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indeks untuk tabel `tagihan`
--
ALTER TABLE `tagihan`
  ADD PRIMARY KEY (`tagihan_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indeks untuk tabel `topup`
--
ALTER TABLE `topup`
  ADD PRIMARY KEY (`topup_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indeks untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`transaksi_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indeks untuk tabel `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `ktp_id` (`ktp_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `admin`
--
ALTER TABLE `admin`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `admin_gaji`
--
ALTER TABLE `admin_gaji`
  MODIFY `gaji_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `admin_notifikasi`
--
ALTER TABLE `admin_notifikasi`
  MODIFY `notifikasi_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `autodebit`
--
ALTER TABLE `autodebit`
  MODIFY `autodebit_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `customer`
--
ALTER TABLE `customer`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `inbox`
--
ALTER TABLE `inbox`
  MODIFY `inbox_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `invoice`
--
ALTER TABLE `invoice`
  MODIFY `invoice_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `notifikasi_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `pinjaman`
--
ALTER TABLE `pinjaman`
  MODIFY `pinjaman_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `riwayat_pinjaman`
--
ALTER TABLE `riwayat_pinjaman`
  MODIFY `riwayat_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `saldo`
--
ALTER TABLE `saldo`
  MODIFY `saldo_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `tagihan`
--
ALTER TABLE `tagihan`
  MODIFY `tagihan_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `topup`
--
ALTER TABLE `topup`
  MODIFY `topup_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `transaksi_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `user`
--
ALTER TABLE `user`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `admin`
--
ALTER TABLE `admin`
  ADD CONSTRAINT `admin_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Ketidakleluasaan untuk tabel `admin_gaji`
--
ALTER TABLE `admin_gaji`
  ADD CONSTRAINT `admin_gaji_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`);

--
-- Ketidakleluasaan untuk tabel `admin_notifikasi`
--
ALTER TABLE `admin_notifikasi`
  ADD CONSTRAINT `admin_notifikasi_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`),
  ADD CONSTRAINT `admin_notifikasi_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Ketidakleluasaan untuk tabel `autodebit`
--
ALTER TABLE `autodebit`
  ADD CONSTRAINT `autodebit_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `autodebit_ibfk_2` FOREIGN KEY (`pinjaman_id`) REFERENCES `pinjaman` (`pinjaman_id`);

--
-- Ketidakleluasaan untuk tabel `customer`
--
ALTER TABLE `customer`
  ADD CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Ketidakleluasaan untuk tabel `inbox`
--
ALTER TABLE `inbox`
  ADD CONSTRAINT `inbox_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `inbox_ibfk_2` FOREIGN KEY (`pinjaman_id`) REFERENCES `pinjaman` (`pinjaman_id`);

--
-- Ketidakleluasaan untuk tabel `invoice`
--
ALTER TABLE `invoice`
  ADD CONSTRAINT `invoice_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `invoice_ibfk_2` FOREIGN KEY (`transaksi_id`) REFERENCES `transaksi` (`transaksi_id`);

--
-- Ketidakleluasaan untuk tabel `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD CONSTRAINT `notifikasi_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Ketidakleluasaan untuk tabel `pinjaman`
--
ALTER TABLE `pinjaman`
  ADD CONSTRAINT `pinjaman_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `pinjaman_ibfk_2` FOREIGN KEY (`verified_by`) REFERENCES `admin` (`admin_id`);

--
-- Ketidakleluasaan untuk tabel `riwayat_pinjaman`
--
ALTER TABLE `riwayat_pinjaman`
  ADD CONSTRAINT `riwayat_pinjaman_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `riwayat_pinjaman_ibfk_2` FOREIGN KEY (`pinjaman_id`) REFERENCES `pinjaman` (`pinjaman_id`);

--
-- Ketidakleluasaan untuk tabel `saldo`
--
ALTER TABLE `saldo`
  ADD CONSTRAINT `saldo_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Ketidakleluasaan untuk tabel `tagihan`
--
ALTER TABLE `tagihan`
  ADD CONSTRAINT `tagihan_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Ketidakleluasaan untuk tabel `topup`
--
ALTER TABLE `topup`
  ADD CONSTRAINT `topup_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Ketidakleluasaan untuk tabel `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `transaksi_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
