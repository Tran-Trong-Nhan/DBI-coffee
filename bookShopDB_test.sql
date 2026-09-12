create database convenienceStoreDB
use convenienceStoreDB
--drop database convenienceStoreDB
--nhà cung cấp
create table Supplier(
	SupID char(6) not null,
	SupName nvarchar(30),
	City  nvarchar(30),
	Address nvarchar(30),
	Country nvarchar(30),
	PhoneNumber char(11),
)
alter table Supplier
	add constraint PK_Supplier_SupID primary key (SupID)

--data

insert into Supplier values ('SUP001', 'PiedTeam', 'HCM', '', 'Viet Nam', '0787806042')
insert into Supplier values ('SUP002', 'Calisa Foods', 'HCM', N'538 Đ.Võ Văn Kiệt, Quận 1', 'Viet Nam', '0868717179')
insert into Supplier values ('SUP003', 'SABECO', 'HCM', N'187 Nguyễn Chí Thanh, Quận 5', 'Viet Nam', '0946477795')
insert into Supplier values ('SUP004', 'Tum Machines', 'HCM', N'11 Nguyễn Bỉnh Khiêm, Quận 1', 'Viet Nam', '0978258951')
insert into Supplier values ('SUP005', 'Christian Dior S.E', 'Paris', 'S.Montaigne, Paris', 'France', '02836364243')
insert into Supplier values ('SUP006', 'Vingroup', N'Hà Nội', N'7 Bằng Lăng 1, Q. Long Biên', 'Viet Nam', '02439749999')
insert into Supplier values ('SUP007', 'MeatDeli',  N'Hà Nội', N'64 Cầu Am, quận Hà Đông', 'Viet Nam', '18006828')
---------------------------------------------------------------------

--chủng loại
create table Category(
	CategoryID char(7) not null,
	CategoryName nvarchar(30),
	Description nvarchar(100),
)
alter table Category
	add constraint PK_Category_CategoryID primary key (CategoryID)

--data
insert into Category values('CATE001', 'course', 'a set of classes of study')
insert into Category values('CATE002', 'bag', 'flexible or carrying something')
insert into Category values('CATE003', 'beer', 'alcoholic drink')
insert into Category values('CATE004', 'clothes', 'pant or shirt')
insert into Category values('CATE005', 'sea food', 'sea fish, served as food')
insert into Category values('CATE006', 'meat', 'the flesh of an animal as food')
insert into Category values('CATE007', 'moto', 'powerful motorcycle')
insert into Category values('CATE008', 'car', 'a four-wheeled road vehicle')
---------------------------------------------------------------------

--sản phẩm
create table Product(
	ProID char(6) not null,
	ProName nvarchar(30),
	Price money,
	CategoryID char(7) not null,
)
alter table Product
	add constraint PK_Product_ProID primary key (ProID)
alter table Product
	add constraint FK_Product_CategoryID foreign key (CategoryID) references Category(CategoryID)

--data
insert into Product values ('PRO001', 'Tiger', '14000', 'CATE003')
insert into Product values ('PRO002', 'DBI SQL server', '4000000', 'CATE001')
insert into Product values ('PRO003', 'Vespa CDior', '14000000000', 'CATE007')
insert into Product values ('PRO004', 'Amina Muaddi', '25124000', 'CATE004')
insert into Product values ('PRO005', 'pork shank', '56000', 'CATE006')
insert into Product values ('PRO006', 'lean meat', '190000', 'CATE006')
insert into Product values ('PRO007', 'VinFast Lux A 2.0', '1115000000', 'CATE008')
insert into Product values ('PRO008', 'De Jouy Embroidery', '8000000', 'CATE002')
insert into Product values ('PRO009', 'crab', '1200000', 'CATE005')
insert into Product values ('PRO010', 'squid', '800000', 'CATE005')
---------------------------------------------------------------------

--Đơn nhập
create table InputBill(
	InputID char(8) not null,
	SupID char(6) not null,
	ProID char(6) not null,
	Amount int,
	InputDate date,
)
alter table InputBill
	add constraint PK_InputBill_InputID primary key (InputID)
alter table InputBill
	add constraint FK_InputBill_SupID foreign key (SupID) references Supplier(SupID)
alter table InputBill
	add constraint FK_InputBill_ProID foreign key (ProID) references Product(ProID)


create table Barn(
	ProID char(6) not null,
	Amount int not null,
)
alter table Barn
	add constraint FK_Barn_ProID foreign key (ProID) references Product(ProID)
alter table Barn
	add constraint UQ_Barn_ProID unique (ProID)

--trigger nhập  1 sản phẩm chưa tồn tại trong kho
--			và nạp thêm sản phẩm nếu kho có sản phẩm đó rồi
CREATE TRIGGER trg_CreatNewItemBarn ON InputBill AFTER INSERT AS 
BEGIN
	DECLARE @Count INT;
	DECLARE @Pro char(6);
	DECLARE @Amount INT;
	select @Count = count(ProID) from Barn where ProID = (select ProID from inserted);
	select @Pro = ProID, @Amount = Amount from inserted;
	if @Count = 0
		insert into Barn values (@Pro , @Amount);
	else
		UPDATE Barn
		SET Barn.Amount = Barn.Amount + (
			SELECT Amount
			FROM inserted
			WHERE ProID = Barn.ProID
		)
		FROM Barn
		JOIN inserted ON Barn.ProID = inserted.ProID
END
--drop trigger trg_CreatNewItemBarn
--trigger cập nhất số lượng kho khi input cập nhật
CREATE TRIGGER trg_updateInputBill on InputBill after update AS
BEGIN
   UPDATE Barn SET Barn.Amount = Barn.Amount +
	   (SELECT Amount FROM inserted WHERE ProID = Barn.ProID) -
	   (SELECT Amount FROM deleted WHERE ProID = Barn.ProID)
   FROM Barn 
   JOIN deleted ON Barn.ProID = deleted.ProID
end
--drop trigger trg_updateInputBill
--trigger cập nhật số lượng kho khi input xóa đơn
create TRIGGER trg_RemoveInputBill ON InputBill FOR DELETE AS 
BEGIN
	UPDATE barn
	SET barn.Amount = barn.Amount - (SELECT Amount FROM deleted WHERE ProID = barn.ProID)
	FROM barn 
	JOIN deleted ON barn.ProID = deleted.ProID
END
--drop trigger trg_RemoveInputBill
--data
insert into InputBill values ('INPUT001', 'SUP001', 'PRO002',30, '2022-04-21')
insert into InputBill values ('INPUT002', 'SUP001', 'PRO001',100, '2021-04-21')
insert into InputBill values ('INPUT003', 'SUP003', 'PRO001',1000, '2020-04-21')
insert into InputBill values ('INPUT004', 'SUP007', 'PRO006',1000, '2022-02-21')
insert into InputBill values ('INPUT005', 'SUP007', 'PRO005',1000, '2022-02-21')

insert into InputBill values ('INPUT006', 'SUP005', 'PRO008',10, '2022-02-21')
insert into InputBill values ('INPUT007', 'SUP005', 'PRO004',20, '2022-02-21')
insert into InputBill values ('INPUT008', 'SUP005', 'PRO003',10, '2022-02-21')

insert into InputBill values ('INPUT009', 'SUP002', 'PRO009',1000, '2022-02-21')
insert into InputBill values ('INPUT010', 'SUP002', 'PRO010',1000, '2022-02-21')

insert into InputBill values ('INPUT011', 'SUP006', 'PRO007',100, '2022-02-21')
insert into InputBill values ('INPUT012', 'SUP006', 'PRO005',1000, '2022-02-21')
insert into InputBill values ('INPUT013', 'SUP006', 'PRO006',1000, '2022-02-21')
insert into InputBill values ('INPUT014', 'SUP006', 'PRO010',1000, '2022-02-21')
insert into InputBill values ('INPUT015', 'SUP006', 'PRO010',500, '2022-02-21')
---------------------------------------------------------------------

--Nhân sự
create table Employee(
	EmpID char(6) not null,
	FirstName nvarchar(30),
	LastName nvarchar(30),
	Title nvarchar(30),
	City  nvarchar(50),
	Address nvarchar(50),
	Country nvarchar(50),
	Birthday date,
)
alter table Employee
	add constraint PK_Employee_EmpID primary key (EmpID)
--data
insert into Employee values('Emp001', N'Điệp', N'Lê', N'Mentor', N'HCM', N'115/13 Đình Phong Phú, Quận 9', N'VietNam', '1999-04-22');
insert into Employee values('Emp002', N'Rumina', N'Yuuki', N'Promotion', N'Tokyo', N'Azumadori_mohiyo', N'Japan', '1995-04-25');
insert into Employee values('Emp003', N'Tom', N'Holland', N'Telesale', N'London', N'Kingston upon Thames', N'UK', '1996-06-1');
insert into Employee values('Emp004', N'Leonardo', N'DiCaprio', N'Telesale', N'California', N'LA', N'USA', '1974-11-11');
insert into Employee values('Emp005', N'Willard', N'Smith', N'Telesale', N'Pennsylvania', N'Philadelphia', N'USA', '1968-09-25');
insert into Employee values('Emp006', N'Robert', N'Downey', N'Telesale', N'NY', N'Manhattan', N'USA', '1965-04-4');
insert into Employee values('Emp007', N'Dwayne', N'Johnson', N'Telesale', N'California', N'Hayward', N'USA', '1972-05-2');
insert into Employee values('Emp008', N'Thomas', N'Cruise', N'Promotion', N'NY', N'Syracuse', N'USA', '1962-07-3');
insert into Employee values('Emp009', N'Scarlett', N'Johansson', N'Promotion', N'NY', N'Manhattan', N'USA', '1984-11-22');
insert into Employee values('Emp010', N'Angelina', N'Jolie', N'Promotion', N'California', N'LA', N'USA', '1975-06-4');
insert into Employee values('Emp011', N'Anne', N'Hathaway', N'Telesale', N'NY', N'Brooklyn', N'USA', '1982-11-12');

insert into Employee values('Emp012', N'O''Veny', N'Osiea', N'Telesale', N'California', N'LA', N'USA', '1995-05-3');
insert into Employee values('Emp013', N'Enno''s', N'Toles''t', N'Telesale', N'California', N'LA', N'USA', '1990-06-3');
select * from Employee
---------------------------------------------------------------------

--khách hàng
create table Customer(
	CusID char(6) not null,
	FirstName nvarchar(30),
	LastName nvarchar(30),
	Type nvarchar(30),
	City  nvarchar(30),
	Address nvarchar(30),
	Country nvarchar(30),
	PhoneNumber char(11),
	Birthday date,
)
alter table Customer
	add constraint PK_Customer_CusID primary key (CusID)
--data
insert into Customer values ('CUS001',N'Annie',N'Milly',N'Silver',N'London',N'Kynance Mews',N'UK',N'24091023',N'1991-12-1');
insert into Customer values ('CUS002',N'Luios',N'Park',N'Gold',N'California',N'Agoura Hills',N'USA',N'25091023',N'1993-10-1');
insert into Customer values ('CUS003',N'Monika',N'Holand',N'Gold',N'California',N'Pacific Coast',N'USA',N'0907291232',N'2001-10-2');
insert into Customer values ('CUS004',N'Roney',N'Aber',N'Gold',N'London',N'Wilton Crescent',N'UK',null,N'1999-2-2');
insert into Customer values ('CUS005',N'Harry',N'Menki',N'Silver',N'NY',N' Union Square Green',N'USA',null,N'1984-12-3');
insert into Customer values ('CUS006',N'Hồng',N'Lê',N'Gold',N'Hà Nội',N'Hàng Mã',N'Vietnam',null,N'1985-4-25');

insert into Customer values ('CUS011',N'Tuấn',N'Lê',N'Gold',null,N'Colville Place, Fitzrovia',N'UK',null,N'2001-3-12');
insert into Customer values ('CUS012',N'Hùng',N'Bá',N'Diamon',null,N'Shinjuku',N'Japan',null,N'2000-4-12');
insert into Customer values ('CUS013',N'Tiệp',N'Phùng',N'Silver',null,N'Fournier, Spitalfields',N'UK',null,N'2002-1-1');

insert into Customer values ('CUS007',N'Vương',N'Phạm',N'Silver',N'London',N'Hillgate Village',N'UK',N'7072229332',N'2000-9-21');
insert into Customer values ('CUS008',N'Billy',N'Jean',N'Gold',N'London',N'Colville Place, Fitzrovia',N'UK',null,N'2001-3-12');
insert into Customer values ('CUS009',N'Charlet',N'Parmen',N'Diamon',N'Tokyo',N'Shinjuku',N'Japan',null,N'1989-11-27');
insert into Customer values ('CUS010',N'Unma',N'Putaky',N'Silver',N'London',N'Fournier, Spitalfields',N'UK',null,N'1993-8-20');
---------------------------------------------------------------------

--thông tin của bên giao hàng
create table Shipper(
	ShipID char(7) not null,
	CompanyName nvarchar(30),
	PhoneNumber char(11),
)
alter table Shipper
	add constraint PK_Shipper_ShipID primary key (ShipID)
--data
insert into Shipper values ('SHIP001', 'Viettel Post', '19008095')
insert into Shipper values ('SHIP002', 'Giaohangnhanh', '1900 636677')
insert into Shipper values ('SHIP003', 'Giaohangtietkiem', '1900 6092')
insert into Shipper values ('SHIP004', 'Ahamove', '1900 545411')
---------------------------------------------------------------------
--đơn đặt hàng
create table Orders(
	OrdID char(6) not null,
	CustomerID char(6) not null,
	EmpID char(6) not null,
	RequiredDate date,
	ShippedDate date,
	Freight float,
	ShipID char(7) not null,
	ShipAddress nvarchar(30),
	ShipCity nvarchar(30),
	ShipCountry nvarchar(30),
)
alter table Orders
	add constraint PK_Orders_OrdID primary key (OrdID)
alter table Orders
	add constraint FK_Orders_CustomerID foreign key (CustomerID) references Customer(CusID)
alter table Orders
	add constraint FK_Orders_EmpID foreign key (EmpID) references Employee(EmpID)
alter table Orders
	add constraint FK_Orders_ShipID foreign key (ShipID) references Shipper(ShipID)
--data
insert into Orders values ('ORD001',N'CUS001',N'EMP002',N'2021-2-2','2021-2-1', 3,'SHIP001',null, N'London',N'UK')
insert into Orders values ('ORD002',N'CUS006',N'EMP001',null,'2021-2-1', 12,'SHIP002',null, N'London',N'UK')
insert into Orders values ('ORD003',N'CUS002',N'EMP003',null,'2022-2-1', 15,'SHIP001',null, N'California',N'USA')
insert into Orders values ('ORD004',N'CUS003',N'EMP002',null,'2019-2-1', 17,'SHIP003',null, N'Tokyo',N'Japan')
insert into Orders values ('ORD005',N'CUS005',N'EMP004',null,'2018-2-1', 90,'SHIP001',null, N'NY',N'USA')
insert into Orders values ('ORD006',N'CUS005',N'EMP006',N'2021-12-4',N'2021-12-3', 101,'SHIP002',null, N'Hàng Mã',N'VietNam')
insert into Orders values ('ORD007',N'CUS004',N'EMP005',N'2019-2-22',N'2019-2-21', 100,'SHIP001',null, N'London',N'UK')
insert into Orders values ('ORD008',N'CUS006',N'EMP003',N'2020-2-2',N'2020-2-1', 99,'SHIP002',null, N'California',N'USA')
insert into Orders values ('ORD009',N'CUS009',N'EMP001',N'2022-5-30',N'2022-5-29', 200,'SHIP001',null, N'London',N'UK')
insert into Orders values ('ORD010',N'CUS007',N'EMP004',N'2021-12-14',N'2021-12-13', 120,'SHIP001',null, N'NY',N'USA')
insert into Orders values ('ORD011',N'CUS001',N'EMP001',N'2022-2-2',N'2022-2-1', 300,'SHIP001',null, N'London',N'UK')
insert into Orders values ('ORD012',N'CUS005',N'EMP006',N'2022-2-2',N'2022-2-1', 200,'SHIP003',null, N'London',N'UK')
insert into Orders values ('ORD013',N'CUS001',N'EMP004',N'2019-12-19',N'2019-12-18', 102,'SHIP001',null, N'London',N'UK')
insert into Orders values ('ORD014',N'CUS004',N'EMP001',N'2018-4-22',N'2018-4-21', 90,'SHIP004',null, N'Hàng Mã',N'VietNam')
insert into Orders values ('ORD015',N'CUS009',N'EMP001',null,'2018-1-31', 60,'SHIP003',null, N'London',N'UK')
insert into Orders values ('ORD016',N'CUS002',N'EMP001',N'2017-6-25',N'2017-6-24', 90,'SHIP003',null, N'California',N'USA')
insert into Orders values ('ORD017',N'CUS001',N'EMP001',N'2018-10-17',N'2018-10-16', 12,'SHIP001',null, N'London',N'UK')
insert into Orders values ('ORD018',N'CUS004',N'EMP003',N'2019-09-06',N'2019-09-05', 17,'SHIP001',null, N'Hàng Mã',N'VietNam')
insert into Orders values ('ORD019',N'CUS006',N'EMP001',N'2023-12-30',N'2023-12-29', 17,'SHIP003',null, N'London',N'UK')
insert into Orders values ('ORD020',N'CUS005',N'EMP005',N'2022-4-22',N'2022-4-21', 90,'SHIP004',null, N'California',N'USA')
insert into Orders values ('ORD021',N'CUS001',N'EMP008',N'2012-12-12',N'2012-12-11', 120,'SHIP001',null, N'London',N'UK')
insert into Orders values ('ORD022',N'CUS007',N'EMP006',N'2022-02-02',N'2022-02-01', 60,'SHIP001',null, N'NY',N'USA')
insert into Orders values ('ORD023',N'CUS001',N'EMP010',N'2020-6-12',N'2020-6-11', 90,'SHIP004',null, N'London',N'UK')
insert into Orders values ('ORD024',N'CUS002',N'EMP001',N'2016-7-12',N'2016-7-11', 120,'SHIP002',null, N'NY',N'USA')
insert into Orders values ('ORD025',N'CUS001',N'EMP009',N'2021-12-21',N'2021-12-20',200,'SHIP004',null, N'Tokyo',N'Japan')
select  * from Orders
---------------------------------------------------------------------

create table OrdersDetail(
	OrdID char(6) not null,
	ProID char(6) not null,
	Quantity int,
	Discount float,
	OrderDate date
)
alter table OrdersDetail
	add constraint FK_Orders_OrdID foreign key (OrdID) references Orders(OrdID)
alter table OrdersDetail
	add constraint FK_Orders_ProID foreign key (ProID) references Product(ProID)

--trigger thêm mới đơn hàng thì bên kho sẽ xóa bớt

CREATE TRIGGER trg_CreateOrdersDetail ON OrdersDetail AFTER INSERT AS 
BEGIN
	update Barn 
	set Amount = Amount - (select Quantity from inserted where ProID = Barn.ProID)
	from Barn join inserted on Barn.ProID = inserted.ProID
END
--drop trigger trg_CreateOrdersDetail
create TRIGGER trg_DeleteOrdersDetail ON OrdersDetail FOR DELETE AS 
BEGIN
	UPDATE barn
	SET Amount = Amount + (SELECT Quantity FROM deleted WHERE ProID = barn.ProID)
	FROM barn
	JOIN deleted ON barn.ProID = deleted.ProID
END
--drop trigger trg_DeleteOrdersDetail
CREATE TRIGGER trg_updateOrdersDetail on OrdersDetail after update AS
BEGIN
   UPDATE barn SET Amount = Amount -
	   (SELECT Quantity FROM inserted WHERE ProID = barn.ProID) +
	   (SELECT Quantity FROM deleted WHERE ProID = barn.ProID)
   FROM barn
   JOIN deleted ON barn.ProID = deleted.ProID
end
--drop trigger trg_updateOrdersDetail
--data
insert into OrdersDetail values ('ORD001', 'PRO001',2,0, GETDATE())
insert into OrdersDetail values ('ORD001', 'PRO006',20,0, GETDATE())
insert into OrdersDetail values ('ORD001', 'PRO005',90,0.7, GETDATE())
insert into OrdersDetail values ('ORD002', 'PRO001',2,0.5, GETDATE())
insert into OrdersDetail values ('ORD002', 'PRO002',15,0, GETDATE())
insert into OrdersDetail values ('ORD002', 'PRO003',2,0.3, GETDATE())
insert into OrdersDetail values ('ORD002', 'PRO004',1,0, GETDATE())
insert into OrdersDetail values ('ORD003', 'PRO004',4,0, GETDATE())
insert into OrdersDetail values ('ORD003', 'PRO005',5,1, GETDATE())
insert into OrdersDetail values ('ORD003', 'PRO001',10,0, GETDATE())
insert into OrdersDetail values ('ORD003', 'PRO006',1,0, GETDATE())
insert into OrdersDetail values ('ORD004', 'PRO008',3,0.4, GETDATE())
insert into OrdersDetail values ('ORD004', 'PRO010',2,0, GETDATE())
insert into OrdersDetail values ('ORD004', 'PRO009',7,0.5, GETDATE())
insert into OrdersDetail values ('ORD005', 'PRO009',9,0, GETDATE())
---------------------------------------------------------------------

select * from Supplier
select * from Category
select * from Product
select * from barn
select * from Customer
select * from Employee
select * from Shipper
select * from Orders
select * from OrdersDetail

--BACKUP DATABASE convenienceStoreDB TO DISK = 'H:\03-DBI\DBIGiaoTrinh2022\libraryManagementDB\convenienceStoreDB.BAK'
--Mới comment hàng trên nha
--Alo alo đang chỉnh mà chưa biết gì hết
