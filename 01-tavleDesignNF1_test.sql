--01-tableDesignNF1
--SQL gồm DDL DML DCL
/*
DDL (CREATE ALTER DROP RENAME)
DML (SELECT INSERT DELETE UPDATE)
DCL
*/
--Chương này tập trung vào DDL để học cách thiết kế table sao cho chuẩn và tại sao phải thiết kế như vậy ==> CHƯƠNG RẤT QUAN TRỌNG

--VD: Tôi có nhu cầu lưu thông tin của các profile ứng viên gồm các thông tin sau:
--	mã,tên,ngày tháng năm sinh, gender, email, phoneNumber
CREATE DATABASE DBK21_tableDesign
USE DBK21_tableDesign

CREATE TABLE ProfileV0(
	ID char(8),
	Name nvarchar(50),
	DOB DATE, --string yyyy-MM-dd
	Gender char(1),
	Email varchar(50),
	PhoneNumber char(120)
)

INSERT INTO ProfileV0 VALUES ('SE123456',N'Nguyễn Thông','1985-05-25','F','ntThong@gmail.com','091234,091235,097234')

--Tìm sdt 091234
SELECT * FROM ProfileV0
WHERE PhoneNumber LIKE '%091234%'
--Trong MySQL nó sẽ lưu data theo kiến trúc B-tree

--An
--Anh
--Ban
--Ben
--Canh

--like 'an%' -- tìm prefix (tìm tiền tố. VD tìm sđt có 3 số đầu là 091,...) kích hoạt B-tree --> Mấy cái bày dạng này thì like sẽ có tốc độ truy xuất hơn hoặc bằng '='
--Toán tử = 'mạnh hơn' toán tử like? không biết và phải dựa vào index và dựa vào trường hợp nữa

--Trigram index () + GIN index (Có tác dụng sắp xếp lại thành B-tree) --> Tuy nhiên MySQL không có combo này mà chỉ có pử postgre
-- Về bản chất vẫn lưu được đa trị trong SQL nhưng hiệu xuất như shit thôi. Lí do thì là hàng ở trên
--NF1: đừng lưu đa trị

--Về nhà tìm hiểu trigram có có giống fulltext search
---------------------------------

CREATE TABLE ProfileV1(
	ID char(8),
	Name nvarchar(50),
	DOB DATE, --string yyyy-MM-dd
	Gender char(1),
	Email varchar(50),
	PhoneNumber char(11)
)

--Nạp thử data
INSERT INTO ProfileV1
VALUES ('SE123456',N'Nguyễn Thông','1985-05-25','F','ntThong@gmail.com','09x...')

INSERT INTO ProfileV1
VALUES ('SE123456',N'Nguyễn Thông','1985-05-25','F','ntThong@gmail.com','09x...')
/*
Đặt trong tình huống nếu mấy đứa nó là học sinh tiểu học
Và mấy nó dell có đt, dell có mail và đó là mail và sđt là của phụ huynh nó --> được trùng
Bọn nó có thể sinh đôi và cùng tên --> có thể cùng tên và cùng ngày sinh
Giới tính thì tất nhiên có thể trùng

Tuy nhiên không được phép hoàn toàn giống nhau do sẽ ko phân biệt thằng nào với thằng nào
*/

UPDATE ProfileV1 set Gender = 'M' WHERE ID = 'SE123456'

--Không có cột cấm trùng Unique key thì sẽ có trường hợp có 2 hàng trùng nhau 100%
--Từ đó ta không thể chọn ra 1
--Đề xuất: mỗi 1 table nên có "ít nhất 1" cột cấm trùng (key - khóa)
--Trong Profile ai nên là key? (ID, email, PhoneNumber, CMND, BLX)
--> Trong một table có thể có rất nhiều key
	--Những key này gọi là candidate key (key ứng viên) ứng tuyển vị trí primary key (khóa chính)
	--làm sao để chọn khóa chính cho đúng?
	--3 tiêu chí:
		/*
			+ Phù hợp với mục tiêu lưu trữ
			+ Tính hiệu lực thấp nhất (Thằng nào ít được sử dụng nhất thì lấy)
			+ Ít suy luận được thông tin nhất
			--> Tóm lại mục tiêu tìm khóa chính là để tìm được thằng nào ít liên quan đến bên ngoài nhất và chỉ được sử dụng nội bộ bên trong một bảng nhất định thôi
		*/
---------------------------------------------
--Primary kew (PK) = Unique (UQ) + not null
--Bây giờ mình làm bảng V2 có ràng buộc
CREATE TABLE ProfileV2(
	ID char(8) primary key, --unique + not null
	Name nvarchar(50),
	DOB DATE, --string yyyy-MM-dd
	Gender char(1) null,  -- M F L G B T
	Email varchar(50) unique,
	PhoneNumber char(11) unique
)

--unique không cấm NULL nhưng nó cấm trùng

INSERT INTO ProfileV2
VALUES ('SE123456',N'Nguyễn Thông','1985-05-25','F','ntThong@gmail.com','09x...')
INSERT INTO ProfileV2
VALUES ('SE123456',N'Nguyễn Thông','1985-05-25','F','ntThong@gmail.com','09x...')


INSERT INTO ProfileV2
VALUES ('SE123457',N'Nguyễn Thông','1985-05-25',null,null,null)

INSERT INTO ProfileV2
VALUES ('SE123458',null,null,null,null,null)
--PK__ProfileV__3214EC27F872B4F1 đây là thông báo lỗi mà dell bt lỗi bảng nào do cái --> Tệ
--UQ__ProfileV__85FB4E3899389EA2 y chang cái trên, nhiều cái unique quá dell bt cái nào mà sửa

--Mình chưa chặn null tốt, dẫn đến việc có thể để null ở rất nhiều vị trí
-- Thông báo lỗi không rõ ràng (tường minh) dẫn đến việc đọc code khó khăn

-- Không nên lưu Name --> Phải tách firstName và lastName để sau này sắp xếp theo tên | họ

CREATE TABLE ProfileV3(
	ID char(8) not null,
	firstName nvarchar(50) not null,
	lastName nvarchar(30) not null,
	DOB DATE, --string yyyy-MM-dd
	Gender char(1) null,  -- M F L G B T
	Email varchar(50) not null,
	PhoneNumber char(11) not null,
)
--Nên thiết lập cái primary key và unique như thế này để tránh cái vấn đề đã đề cặp trên V2
ALTER TABLE ProfileV3
	ADD CONSTRAINT PK_ProfileV3_ID PRIMARY KEY (ID)

	/*
	ALTER TABLE ProfileV3 DROP PK_ProfileV3_ID
	Xóa thì làm như cái này
	*/

	ALTER TABLE ProfileV3
	ADD CONSTRAINT UQ_ProfileV3_Email Unique (Email)

	ALTER TABLE ProfileV3
	ADD CONSTRAINT UQ_ProfileV3_PhoneNumber Unique (PhoneNumber)

--	CREATE INDEX idx_ProfileV3_email ON ProfileV3(email) --Tìm theo B-tree, rất nhanh nhưng đổi lại phải tạo rất nhiều index --> Cho nên chỉ dùng đối với vùng giá trị rất hay tìm kiếm, Không thì thôi
--Unique với PK nó ràng buộc giá trị nhận vào còn index chỉ tạo các bảng để nó truy xuất thôi