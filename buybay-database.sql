-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 15, 2025 at 02:20 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

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
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `admin_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`admin_id`, `user_id`) VALUES
(1, 1),
(2, 2);

-- --------------------------------------------------------

--
-- Table structure for table `admin_gaji`
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
-- Table structure for table `admin_notifikasi`
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
-- Table structure for table `autodebit`
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
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `customer_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customer_id`, `user_id`) VALUES
(1, 7),
(2, 8),
(3, 9),
(4, 10);

-- --------------------------------------------------------

--
-- Table structure for table `invoice`
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
-- Stand-in structure for view `monitoring_customer`
-- (See below for the actual view)
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
-- Table structure for table `notifikasi`
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
-- Table structure for table `pinjaman`
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
  `verified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `riwayat_pinjaman`
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
-- Table structure for table `saldo`
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
-- Table structure for table `tagihan`
--

CREATE TABLE `tagihan` (
  `tagihan_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `nama_perusahaan` varchar(100) DEFAULT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `bank` varchar(100) DEFAULT NULL,
  `tanggal_notifikasi` date DEFAULT NULL,
  `jumlah` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `topup`
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
-- Table structure for table `transaksi`
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
-- Table structure for table `user`
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
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `nama_lengkap`, `email`, `password`, `alamat_domisili`, `no_telp`, `tanggal_lahir`, `jenis_kelamin`, `ktp_id`, `status_user`) VALUES
(1, 'putra budi rahmatwati suwiratih ', 'budi@mail.com', 'admin123', 'Jl. Surabaya jawa timur No.1', '081123321', '2000-01-01', 'Laki-laki', '1111111111111111', 'Admin'),
(2, 'firmandono sita sarini', 'sita@mail.com', 'admin321', 'Jl. malang surabaya No.2', '082123321', '2001-01-01', 'Perempuan', '2222222222222222', 'Admin'),
(7, 'Rina Marlina suningsih', 'rina@mail.com', 'rina123', 'Jl. kartini No.1', '089123321', '2002-03-03', 'Perempuan', '0987654321', 'Customer'),
(8, 'Bagas Prasetyo Satria Kekar', 'bagas@mail.com', 'bagas123', 'Jl. pahlawan nusantara No.2', '088123321', '2001-04-04', 'Laki-laki', '987654321', 'Customer'),
(9, 'Dina Aulia Putriwan', 'dina@mail.com', 'dina123', 'Jl. imam bonjol No.3', '087123321', '2005-05-05', 'Perempuan', '1234567890', 'Customer'),
(10, 'Andi Wijaya Kaseng Mujoyo', 'andi@mail.com', 'andi123', 'Jl. raih pati No.4', '086123321', '2004-06-06', 'Laki-laki', '123456789', 'Customer');

-- --------------------------------------------------------

--
-- Structure for view `monitoring_customer`
--
DROP TABLE IF EXISTS `monitoring_customer`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `monitoring_customer`  AS SELECT `c`.`customer_id` AS `customer_id`, `u`.`nama_lengkap` AS `nama_customer`, `u`.`email` AS `email`, `u`.`no_telp` AS `no_telp`, `p`.`pinjaman_id` AS `pinjaman_id`, `p`.`jumlah_pinjaman` AS `jumlah_pinjaman`, `p`.`tanggal_jatuh_tempo` AS `tanggal_jatuh_tempo`, `p`.`status` AS `status_pinjaman`, `t`.`tagihan_id` AS `tagihan_id`, `t`.`nama_perusahaan` AS `nama_perusahaan`, `t`.`jumlah` AS `jumlah_tagihan`, `t`.`tanggal_notifikasi` AS `tanggal_notifikasi` FROM (((`customer` `c` join `user` `u` on(`c`.`user_id` = `u`.`user_id`)) left join `pinjaman` `p` on(`c`.`customer_id` = `p`.`customer_id` and `p`.`status` = 'accepted')) left join `tagihan` `t` on(`c`.`customer_id` = `t`.`customer_id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `admin_gaji`
--
ALTER TABLE `admin_gaji`
  ADD PRIMARY KEY (`gaji_id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Indexes for table `admin_notifikasi`
--
ALTER TABLE `admin_notifikasi`
  ADD PRIMARY KEY (`notifikasi_id`),
  ADD KEY `admin_id` (`admin_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `autodebit`
--
ALTER TABLE `autodebit`
  ADD PRIMARY KEY (`autodebit_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `pinjaman_id` (`pinjaman_id`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customer_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `invoice`
--
ALTER TABLE `invoice`
  ADD PRIMARY KEY (`invoice_id`),
  ADD UNIQUE KEY `nomor_invoice` (`nomor_invoice`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `transaksi_id` (`transaksi_id`);

--
-- Indexes for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`notifikasi_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `pinjaman`
--
ALTER TABLE `pinjaman`
  ADD PRIMARY KEY (`pinjaman_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `verified_by` (`verified_by`);

--
-- Indexes for table `riwayat_pinjaman`
--
ALTER TABLE `riwayat_pinjaman`
  ADD PRIMARY KEY (`riwayat_id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `pinjaman_id` (`pinjaman_id`);

--
-- Indexes for table `saldo`
--
ALTER TABLE `saldo`
  ADD PRIMARY KEY (`saldo_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `tagihan`
--
ALTER TABLE `tagihan`
  ADD PRIMARY KEY (`tagihan_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `topup`
--
ALTER TABLE `topup`
  ADD PRIMARY KEY (`topup_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`transaksi_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `ktp_id` (`ktp_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `admin_gaji`
--
ALTER TABLE `admin_gaji`
  MODIFY `gaji_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `admin_notifikasi`
--
ALTER TABLE `admin_notifikasi`
  MODIFY `notifikasi_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `autodebit`
--
ALTER TABLE `autodebit`
  MODIFY `autodebit_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `invoice`
--
ALTER TABLE `invoice`
  MODIFY `invoice_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `notifikasi_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pinjaman`
--
ALTER TABLE `pinjaman`
  MODIFY `pinjaman_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `riwayat_pinjaman`
--
ALTER TABLE `riwayat_pinjaman`
  MODIFY `riwayat_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `saldo`
--
ALTER TABLE `saldo`
  MODIFY `saldo_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tagihan`
--
ALTER TABLE `tagihan`
  MODIFY `tagihan_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `topup`
--
ALTER TABLE `topup`
  MODIFY `topup_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `transaksi_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin`
--
ALTER TABLE `admin`
  ADD CONSTRAINT `admin_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `admin_gaji`
--
ALTER TABLE `admin_gaji`
  ADD CONSTRAINT `admin_gaji_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`);

--
-- Constraints for table `admin_notifikasi`
--
ALTER TABLE `admin_notifikasi`
  ADD CONSTRAINT `admin_notifikasi_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`),
  ADD CONSTRAINT `admin_notifikasi_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Constraints for table `autodebit`
--
ALTER TABLE `autodebit`
  ADD CONSTRAINT `autodebit_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `autodebit_ibfk_2` FOREIGN KEY (`pinjaman_id`) REFERENCES `pinjaman` (`pinjaman_id`);

--
-- Constraints for table `customer`
--
ALTER TABLE `customer`
  ADD CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `invoice`
--
ALTER TABLE `invoice`
  ADD CONSTRAINT `invoice_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `invoice_ibfk_2` FOREIGN KEY (`transaksi_id`) REFERENCES `transaksi` (`transaksi_id`);

--
-- Constraints for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD CONSTRAINT `notifikasi_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Constraints for table `pinjaman`
--
ALTER TABLE `pinjaman`
  ADD CONSTRAINT `pinjaman_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `pinjaman_ibfk_2` FOREIGN KEY (`verified_by`) REFERENCES `admin` (`admin_id`);

--
-- Constraints for table `riwayat_pinjaman`
--
ALTER TABLE `riwayat_pinjaman`
  ADD CONSTRAINT `riwayat_pinjaman_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  ADD CONSTRAINT `riwayat_pinjaman_ibfk_2` FOREIGN KEY (`pinjaman_id`) REFERENCES `pinjaman` (`pinjaman_id`);

--
-- Constraints for table `saldo`
--
ALTER TABLE `saldo`
  ADD CONSTRAINT `saldo_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Constraints for table `tagihan`
--
ALTER TABLE `tagihan`
  ADD CONSTRAINT `tagihan_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Constraints for table `topup`
--
ALTER TABLE `topup`
  ADD CONSTRAINT `topup_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);

--
-- Constraints for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `transaksi_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
