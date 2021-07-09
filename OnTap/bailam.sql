use QuanLyGiaoVu
go

-- Cau 1. Tạo bảng KETQUA(namhoc, hocky,masv,mamh,lanthi,diemLT,diemTH)
create table KETQUA
(
	namhoc nvarchar(9) not null,
	hocky int not null,
	masv char(5) not null,
	mamh varchar(4) not null,
	lanthi int not null,
	diemLT float,
	diemTH float,

	primary key(namhoc, hocky, masv, mamh, lanthi),
)
go

-- Cau 2. Tạo rang buộc khóa ngoại cho bảng KETQUA
alter table KETQUA add constraint fk_KETQUA_MONHOC
foreign key (mamh) references MONHOC (mamh)

alter table KETQUA add constraint fk_KETQUA_SINHVIEN
foreign key (masv) references SINHVIEN (masv)

go

-- Cau 3. Tạo kiểm tra ràng buộc Check1 cho các cột DiemLT, DiemTH như sau: 0<=DiemLT<=10, 0<= DiemTH <=10
alter table KETQUA add constraint Check1
check ((DiemLT between 0 and 10) and (DiemTH between 0 and 10))
go

-- Cau 4. Thực thi file Insert_ketqua.sql để them dữ liệu vào bảng KETQUA
-- Cau 5. Tạo kiểm tra ràng buộc Check2 cho cột NgaySinh bảng SinhVien như sau: Tính tới thời điểm hiện tại sinh viên nhập học phải lớn hơn 17 tuổi.
alter table SINHVIEN add constraint Check2
check (datediff(year, ngaysinh, getdate()) > 17)
go

/* Cau 6. Tạo mới 1 bảng chứa danh sách điểm của môn ‘Cấu Trúc Dữ Liêu’ với lược đồ quan hệ
như sau: DIEM_CTDL(masv, hosv, tensv,tenmh,diemLT,diemTH,namhoc,hocky,lanthi)
Sau đó, thêm vào bảng DIEM_CTDL danh sách điểm của môn ‘Cấu Trúc Dữ Liêu’.
*/
create table DIEM_CTDL
(
	masv char(5) not null,
	hosv nvarchar(20) null,
	tensv nvarchar(10) null,
	tenmh nvarchar(50) null,
	diemLT float null,
	diemTH float null,
	namhoc nvarchar(9) not null,
	hocky int not null,
	lanthi int not null,
)
go

insert into DIEM_CTDL
select sv.masv, hosv, tensv, tenmh, diemLT, diemTH, namhoc, hocky, lanthi
from SINHVIEN as sv join KETQUA as kq on sv.masv = kq.masv
					join MONHOC as mh on kq.mamh = mh.mamh
where mh.mamh = 'CTDL'
go

-- Cau 7. Cập nhật sotietLT=sotietLT+sotietTH và sotietTH=0 của môn ‘Sinh học đại cương’.
update MONHOC
set sotietLT=sotietLT+sotietTH, sotietTH = 0
where mamh = 'SHDC'
go

-- Cau 8. Xóa thông tin các sinh viên có diemLT<5 và lanthi=1 ra khỏi bảng DIEM_CTDL
delete DIEM_CTDL
where diemLT <= 5 and lanthi = 1
go

-- Cau 9. Hiển thị danh sách các sinh viên được nhận học bổng, sắp xếp danh sách theo thứ tự giảm dần.
select *
from SINHVIEN
where hocbong is not null
order by hocbong desc

-- Cau 10. Hiển thị danh sách các sinh viên thuộc các khoa có mã là 'CNTT', 'VL', 'QTKD', 'XD'.
select *
from SINHVIEN
where makhoa in ('CNTT', 'VL', 'QTKD', 'XD')

-- Cau 11. Hiển thị danh sách mã sv, họ tên sv và tuổi của tất cả sinh viên, sắp xếp danh sách tăng dần theo tuổi.
select masv, hosv, tensv, (datediff(year, ngaysinh, getdate())) as Tuoi
from SINHVIEN
order by Tuoi asc

-- Cau 12. Hiển thị danh sách các sinh viên sinh quí 4, năm 1996.
select *
from SINHVIEN
where YEAR(ngaysinh) = '1996' and DATEPART(q, ngaysinh) = 4

-- Cau 13. Danh sách tên những môn học được tổ chức cùng ngày thi và cùng giờ thi trong học kỳ 1 năm ‘2014-2015’.
select *
from MONHOC as mh join THI as thi on mh.mamh = thi.mamh
where mh.mamh in (
select thi1.mamh
from THI as thi1 join THI as thi2 on thi1.mamh <> thi2.mamh
and thi1.ngaythi = thi2.ngaythi and thi1.giothi = thi2.giothi
and thi1.hocky = thi2.hocky and thi1.namhoc = thi2.namhoc
where thi1.hocky = 1 and thi1.namhoc = '2014-2015'
)

-- Cau 14. Danh sách mã số và tên của những giảng viên vừa phụ trách dạy lý thuyết vừa phụ trách dạy thực hành cho cùng một môn học.
select *
from GIANGVIEN
where magv in (
select gd1.magv
from GIANGDAY as gd1 join GIANGDAY as gd2 on gd1.magv = gd2.magv
and gd1.phutrach <> gd2.phutrach
where gd1.mamh = gd2.mamh
)

-- Cau 15. Danh sách tên của những môn học có số tín chỉ lớn hơn số tín chỉ của môn ‘Cơ sở dữ liệu’.
select *
from MONHOC
where sotinchi > (
select sotinchi
from MONHOC
where mamh = 'CSDL'
)

-- Cau 16. Danh sách mã số, họ tên những sinh viên đứng đầu về điểm thi lý thuyết môn ‘Cơ sở dữ liệu’.
select *
from SINHVIEN as sv join KETQUA as kq on sv.masv = kq.masv
where kq.mamh = 'CSDL' and kq.diemLT = (
select MAX(kq.diemLT)
from SINHVIEN as sv join KETQUA as kq on sv.masv = kq.masv
where kq.mamh = 'CSDL'
)

-- Cau 17. Danh sách tên của những môn học đứng đầu về số tín chỉ trong số những môn có số tiết lý thuyết bằng với số tiết thực hành.
select top 1 with ties *
from MONHOC as mh1 join MONHOC as mh2 on mh1.mamh = mh2.mamh
where mh1.sotietLT=mh2.sotietTH
order by mh1.sotinchi desc

-- Cau 18. Danh sách mã số và họ tên của những sinh viên có cùng điểm thi LT lần 1 môn ‘Cấu trúc dữ liệu’.
select *
from SINHVIEN as sv join KETQUA as kq on sv.masv = kq.masv
where sv.masv in (
select kq1.masv
from KETQUA as kq1 join KETQUA as kq2 on kq1.masv <> kq2.masv
where kq1.diemLT = kq2.diemLT and kq1.lanthi=kq2.lanthi and kq1.lanthi = 1
and kq1.mamh = kq2.mamh and kq1.mamh = 'CTDL'
)

-- Cau 19. Tạo danh sách các sinh viên trùng tên với nhau.
select sv1.* into SV_TRUNGTEN
from SINHVIEN as sv1 join SINHVIEN as sv2 on sv1.masv <> sv2.masv
where sv1.tensv = sv2.tensv

--select * from SV_TRUNGTEN

-- Cau 20. Danh sách mã số, họ tên sinh viên và tên những môn học mà những sinh viên có đăng ký học và có kết quả thi.
select sv.masv, sv.hosv, sv.tensv, mh.tenmh
from SINHVIEN as sv join DANGKY as dk on sv.masv = dk.masv
join MONHOC as mh on dk.mamh = mh.mamh
where sv.masv in (
select masv 
from KETQUA
)

/* Cau 21. Tạo danh sách có mã số, họ tên các giảng viên và 
mã môn học mà giảng viên được phân công giảng dạy lý thuyết trong năm 2014-2015.
*/
select gv.magv, gv.hogv, gv.tengv, gd.mamh, gd.namhoc, gd.phutrach
from GIANGVIEN as gv join GIANGDAY as gd on gv.magv = gd.magv
where gd.namhoc = '2014-2015' and gd.phutrach = 'LT'

-- Cau 22. Danh sách mã số, họ tên và số lượng thân nhân của mỗi giảng viên.
select tn.magv, gv.hogv, gv.tengv, count(tn.hotentn) as soLuong
from THANNHAN as tn join GIANGVIEN as gv on tn.magv = gv.magv
group by tn.magv, gv.hogv, gv.tengv

-- Cau 23. Danh sách mã số và họ tên giảng viên, tên khoa và tổng số lượng sinh viên của khoa mà giảng viên đang công tác.
select gv.magv, gv.hogv, gv.tengv, sv.makhoa, kh.tenkhoa, count(sv.masv) as soLuongSinhVien
from SINHVIEN as sv join KHOA as kh on sv.makhoa = kh.makhoa
join GIANGVIEN as gv on kh.makhoa = gv.makhoa
group by gv.magv, gv.hogv, gv.tengv, sv.makhoa, kh.tenkhoa

-- Cau 24. Danh sách mã số và tên giảng viên và số môn học mà giảng viên đó được phân công giảng dạy lý thuyết trong học kỳ 1 năm ‘2014-2015’
select gv.magv, gv.hogv, gv.tengv, gd.phutrach, gd.namhoc, count(gd.magv) as soMonDuocPhanCong
from GIANGVIEN as gv join GIANGDAY as gd on gv.magv = gd.magv
where gd.phutrach = 'LT' and gd.hocky = 1 and gd.namhoc = '2014-2015'
group by gv.magv, gv.hogv, gv.tengv, gd.phutrach, gd.namhoc

-- Cau 25. Danh sách mã số và họ tên giảng viên có trên 2 thân nhân.
select tn.magv, gv.hogv, gv.tengv, count(tn.hotentn) as slThanNhan
from THANNHAN as tn join GIANGVIEN as gv on tn.magv = gv.magv
group by tn.magv, gv.hogv, gv.tengv
having count(tn.hotentn) > 2

-- Cau 26. Cho biết mã số và họ tên trưởng khoa có tối thiểu hai thân nhân.
select magv, count(magv) as soLuongThanNhan
from THANNHAN
where magv in (
select gv.magv
from GIANGVIEN as gv join QLYKHOA as ql on gv.magv = ql.magv
where ql.chucvu = 'TK'
)
group by magv
having count(magv) >= 2

-- Cau 27. Danh sách tên của những môn học đã được phân công giảng dạy trong học kỳ 1 năm ‘2014-2015’ nhưng không có sinh viên đăng ký.
select *
from MONHOC
where mamh not in (
select gd.mamh
from MONHOC as mh join GIANGDAY as gd on mh.mamh = gd.mamh
where gd.hocky = 1 and gd.namhoc = '2014-2015'
)

-- Cau 28. Danh sách tên của những sinh viên chưa đăng ký học môn ‘Cấu trúc dữ liệu’ trong học kỳ 1 năm ‘2014-2015’.
select *
from SINHVIEN
where masv not in (
select masv
from DANGKY
where mamh = 'CTDL' and hocky = 1 and namhoc = '2014-2015'
)

-- Cau 29. Danh sách những sinh viên của khoa Công nghệ thông tin đứng đầu về điểm lý thuyết trung bình.
select top 1 with ties sv.masv, sv.hosv, sv.tensv, AVG(diemLT) as DTB_LT
from SINHVIEN as sv join KETQUA as kq on sv.masv = kq.masv
where sv.makhoa = 'CNTT'
group by sv.masv, sv.hosv, sv.tensv
order by AVG(diemLT) desc

-- Cau 30. Danh sách mã số môn học và số lượng sinh viên đăng ký theo từng môn học trong năm học ‘2014-2015’.
select mamh, count(masv) as slsv
from DANGKY
where namhoc = '2014-2015'
group by mamh

-- Cau 31. Danh sách tên của những môn học đứng đầu về số tín chỉ trong số những môn có số tiết lý thuyết bằng với số tiết thực hành.
select top 1 with ties *
from MONHOC as mh1 join MONHOC as mh2 on mh1.mamh = mh2.mamh
where mh1.sotietLT = mh2.sotietTH
order by mh1.sotinchi

/* Cau 32. Danh sách mã số và họ tên của những giảng viên 
đứng đầu về số lượng môn học được phân công giảng dạy lý thuyết trong học kỳ 1 năm ‘2014-2015’. */
select top 1 with ties gd.magv, gv.hogv, gv.tengv, count(gd.mamh) as slMonHocDuocPhanCong
from GIANGDAY as gd join GIANGVIEN as gv on gd.magv = gv.magv
where gd.namhoc = '2014-2015' and gd.hocky = 1
group by gd.magv, gv.hogv, gv.tengv
order by slMonHocDuocPhanCong desc