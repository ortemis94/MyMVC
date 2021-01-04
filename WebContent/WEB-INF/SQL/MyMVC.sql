SHOW USER;
-- USER이(가) "SYS"입니다.

CREATE USER mymvc_user IDENTIFIED BY cclass;
-- User MYMVC_USER이(가) 생성되었습니다.

GRANT CONNECT, RESOURCE, CREATE VIEW, UNLIMITED TABLESPACE TO mymvc_user;
-- Grant을(를) 성공했습니다.

SHOW USER;
-- USER이(가) "MYMVC_USER"입니다.


create table tbl_main_image
(imgno           number not null
,imgfilename     varchar2(100) not null
,constraint PK_tbl_main_image primary key(imgno)
);

create sequence seq_main_image
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

insert into tbl_main_image(imgno, imgfilename) values(seq_main_image.nextval, '미샤.png');  
insert into tbl_main_image(imgno, imgfilename) values(seq_main_image.nextval, '원더플레이스.png'); 
insert into tbl_main_image(imgno, imgfilename) values(seq_main_image.nextval, '레노보.png'); 
insert into tbl_main_image(imgno, imgfilename) values(seq_main_image.nextval, '동원.png'); 

commit;

SELECT imgno, imgfilename
FROM tbl_main_image
ORDER BY imgno ASC;

String sql = "SELECT imgno, imgfilename\n"+
"FROM tbl_main_image\n"+
"ORDER BY imgno ASC";
-- java용 sql


----- **** 회원 테이블 생성 **** -----

DROP TABLE tbl_member PURGE; 
CREATE TABLE tbl_member (
     userid               VARCHAR2(20)  NOT NULL -- 회원 아이디
    ,pwd                  VARCHAR2(200) NOT NULL -- 비밀번호 (SHA-256 암호화 대상)
    ,name                 VARCHAR2(30)  NOT NULL -- 회원명
    ,email                VARCHAR2(200) NOT NULL -- 이메일 (AES-256 암호화/복호화 대상)
    ,mobile               VARCHAR2(200)          -- 연락처 (AES-256 암호화/복호화 대상)
    ,postcode             VARCHAR2(5)            -- 우편번호
    ,address              VARCHAR2(200)          -- 주소
    ,detailaddress        VARCHAR2(200)          -- 상세주소
    ,extraaddress         VARCHAR2(200)          -- 주소참고항목
    ,gender               VARCHAR2(1)            -- 성별   남자:1 / 여자:2
    ,birthday             VARCHAR2(10)            -- 생년월일
    ,coin                 NUMBER DEFAULT 0       -- 코인액
    ,point                NUMBER DEFAULT 0       -- 포인트
    ,registerday          DATE DEFAULT sysdate   -- 가입일자
    ,lastpwdchangedate    DATE DEFAULT sysdate   -- 마지막으로 암호를 변경한 날짜
    ,status               NUMBER(1) DEFAULT 1 NOT NULL   -- 회원탈퇴유뮤  1:사용가능(가입중) / 0:사용불능(탈퇴)
    ,idle                 NUMBER(1) DEFAULT 0 NOT NULL   -- 휴면유무      0:활동중 / 1: 휴면중
    ,CONSTRAINT PK_tbl_member_userid PRIMARY KEY(userid)
    ,CONSTRAINT UQ_tbl_member_email UNIQUE(email)
    ,CONSTRAINT CK_tbl_member_gender CHECK( gender IN('1','2') )
    ,CONSTRAINT CK_tbl_member_status CHECK( status IN(0,1) )
    ,CONSTRAINT CK_tbl_member_idle CHECK( idle IN(0,1) )
);
-- Table TBL_MEMBER이(가) 생성되었습니다.


INSERT INTO tbl_member(userid, pwd, name, email, mobile, postcode, address, detailaddress, extraaddress, gender, birthday)
VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

String sql = "INSERT INTO tbl_member(userid, pwd, name, email, mobile, postcode, address, detailaddress, extraaddress, gender, birthday)\n"+
"VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

SELECT *
FROM tbl_member;


String sql = "SELECT *\n"+
"FROM tbl_member\n"+
"WHERE userid=?";
-- java용 sql


DELETE FROM tbl_member;
COMMIT;


-------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE tbl_loginhistory(
    fk_userid       VARCHAR2(20) NOT NULL,
    logindate      DATE DEFAULT sysdate NOT NULL,
    clientip         VARCHAR2(20) NOT NULL,
    CONSTRAINT FK_tbl_loginhistory FOREIGN KEY(fk_userid) REFERENCES tbl_member(userid) -- 나중에 기록이 남아야 하기 때문에 ON DELETE CASCADE는 넣지 않음.
);

SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender
          , substr(birthday, 1, 4) AS birthyyyy, substr(birthday, 6, 2) AS birthmm, substr(birthday, 9) AS birthdd  
          , coin, point, to_char(registerday, 'yyyy-mm-dd') AS registerday
          , TRUNC( months_between(sysdate, lastpwdchangedate) ) AS pwdchangegap
FROM tbl_member
WHERE status=1 AND  userid = 'eomjh' AND pwd = '18006e2ca1c2129392c66d87334bd2452c572058d406b4e85f43c1f72def10f5';


SELECT *
FROM tbl_loginhistory;

-- 암호를 변경한지 3개월이 초과한 경우
-- 로그인시 "비밀번호를 변경하신지 3개월이 지났습니다. 암호를 변경하세요!!"라는 alert를 띄우기 위해 아래와 같이 한다.
UPDATE tbl_member SET registerday = add_months(registerday, -4)
     , lastpwdchangedate = add_months(lastpwdchangedate, -4) -- 원래의 registerday와 lastpwdchangedate에서 4개월을 뺌.
WHERE userid = 'eomjh';

commit;

-- 마지막으로 로그인을 한지 12개월이 초과한 경우 또는 회원을 가입하고서 로그인을 하지 않은지가 12개월이 초과한 경우
-- 로그인시 "로그인을 한지 1년이 지나서 휴면상태로 되었습니다. 관리자에게 문의 바랍니다."라는 alert를 띄우기 위해 아래와 같이 한다.
UPDATE tbl_member SET registerday = add_months(registerday, -13)
                    , lastpwdchangedate = add_months(lastpwdchangedate, -13)
WHERE userid='kangkc';

UPDATE tbl_loginhistory SET logindate = add_months(logindate, -13)
WHERE fk_userid = 'kangkc';

UPDATE tbl_member SET registerday = add_months(registerday, -14)
                    , lastpwdchangedate = add_months(lastpwdchangedate, -14)
WHERE userid='youks';

commit;

SELECT *
FROM tbl_member;


SELECT *
FROM tbl_loginhistory;

SELECT MAX(logindate) , TRUNC( months_between(sysdate, MAX(logindate)) ) AS lastlogingap
FROM tbl_loginhistory
WHERE fk_userid = 'leess';

SELECT MAX(logindate) , TRUNC( months_between(sysdate, MAX(logindate)) ) AS lastlogingap
FROM tbl_loginhistory
WHERE fk_userid = 'kangkc';


SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender
     , birthyyyy, birthmm, birthdd, coin, point, registerday, pwdchangegap, lastlogingap
FROM
(
SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender
          , substr(birthday, 1, 4) AS birthyyyy, substr(birthday, 6, 2) AS birthmm, substr(birthday, 9) AS birthdd  
          , coin, point, to_char(registerday, 'yyyy-mm-dd') AS registerday
          , TRUNC( months_between(sysdate, lastpwdchangedate) ) AS pwdchangegap
FROM tbl_member
WHERE status=1 AND  userid = 'kangkc' AND pwd = '18006e2ca1c2129392c66d87334bd2452c572058d406b4e85f43c1f72def10f5'
) M
CROSS JOIN
(
SELECT TRUNC( months_between(sysdate, MAX(logindate)) ) AS lastlogingap
FROM tbl_loginhistory
WHERE fk_userid = 'kangkc'
GROUP BY fk_userid 
) H;


--- 회원가입만하고서 로그인을 하지 않은 경우에는 tbl_loginhistory 테이블에 insert 되어진 정보가 없으므로 
--- 마지막으로 로그인한 날짜를 회원가입한 날짜로 보도록 한다.
SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender
     , birthyyyy, birthmm, birthdd, coin, point, registerday, pwdchangegap
     , nvl(lastlogingap, TRUNC( months_between(sysdate, registerday) ) ) AS lastlogingap
FROM
(
SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, gender
          , substr(birthday, 1, 4) AS birthyyyy, substr(birthday, 6, 2) AS birthmm, substr(birthday, 9) AS birthdd  
          , coin, point, to_char(registerday, 'yyyy-mm-dd') AS registerday
          , TRUNC( months_between(sysdate, lastpwdchangedate) ) AS pwdchangegap
FROM tbl_member
WHERE status=1 AND  userid = 'youks' AND pwd = '18006e2ca1c2129392c66d87334bd2452c572058d406b4e85f43c1f72def10f5'
) M
CROSS JOIN
(
SELECT TRUNC( months_between(sysdate, MAX(logindate)) ) AS lastlogingap
FROM tbl_loginhistory
WHERE fk_userid = 'youks'
) H;


UPDATE tbl_member SET coin = coin + '300000'
WHERE userid = 'sist';

SELECT *
FROM tbl_member;

rollback;

---------------------------------------------------------------------------------------------------------------------------------------
-- 오라클에서 프로시저를 사용하여 회원을 대량으로 입력(insert)한다. --
CREATE OR REPLACE PROCEDURE pcd_member_insert
(p_userid    IN  VARCHAR2
,p_name      IN  VARCHAR2
,p_gender    IN  CHAR)
IS
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO tbl_member(userid, pwd, name, email, mobile, postcode, address, detailaddress, extraaddress, gender, birthday)
        VALUES(p_userid||i, '18006e2ca1c2129392c66d87334bd2452c572058d406b4e85f43c1f72def10f5', p_name||i, i||'Qcj8QWTRKn5v/wBgXvrz+TOYrrWHoQqFMuCo7ZgdzQo='||i||i , '7YEIQDsUQcZMThBc3uInnw==', '14256', '경기 광명시 오리로 801', '신동 백호', ' (하안동, 이편한세상센트레빌아파트)', p_gender, '1994-06-06');
    END LOOP;    
END pcd_member_insert;
-- Procedure PCD_MEMBER_INSERT이(가) 컴파일되었습니다.

EXEC pcd_member_insert('hongse', '홍승의', '1');
-- PL/SQL 프로시저가 성공적으로 완료되었습니다.

EXEC pcd_member_insert('iyou', '아이유', '2');
-- PL/SQL 프로시저가 성공적으로 완료되었습니다.

commit;

SELECT *
FROM tbl_member;

-----------------------------------------------------------------------------------------------------------------------------
--- 오라클에서 프로시저를 사용하여 회원을 대량으로 입력(insert)하겠습니다. ---
select * 
from user_constraints
where table_name = 'TBL_MEMBER';

alter table tbl_member
drop constraint UQ_TBL_MEMBER_EMAIL;  -- 이메일을 대량으로 넣기 위해서 어쩔수 없이 email 에 대한 unique 제약을 없애도록 한다. 

select * 
from user_constraints
where table_name = 'TBL_MEMBER';

select *
from user_indexes
where table_name = 'TBL_MEMBER';

drop index UQ_TBL_MEMBER_EMAIL;

select *
from user_indexes
where table_name = 'TBL_MEMBER';

delete from tbl_member 
where name like '홍승의%' or name like '아이유%';

commit;

create or replace procedure pcd_member_insert 
(p_userid  IN  varchar2
,p_name    IN  varchar2
,p_gender  IN  char)
is
begin
     for i in 1..100 loop
         insert into tbl_member(userid, pwd, name, email, mobile, postcode, address, detailaddress, extraaddress, gender, birthday) 
         values(p_userid||i, '18006e2ca1c2129392c66d87334bd2452c572058d406b4e85f43c1f72def10f5', p_name||i, 'Qcj8QWTRKn5v/wBgXvrz+TOYrrWHoQqFMuCo7ZgdzQo=' , 'c5TbkMv3Bk7viPixbC8fwA==', '15864', '경기 군포시 오금로 15-17', '102동 9004호', ' (금정동)', p_gender, '1991-01-27');
     end loop;
end pcd_member_insert;
-- Procedure PCD_MEMBER_INSERT이(가) 컴파일되었습니다.


exec pcd_member_insert('hongse','홍승의','1');
-- PL/SQL 프로시저가 성공적으로 완료되었습니다.
commit;

exec pcd_member_insert('iyou','아이유','2');
-- PL/SQL 프로시저가 성공적으로 완료되었습니다.
commit;


select * 
from tbl_member;


---- ==== 페이징 처리를 위한 SQL문 작성하기 ==== ----
select rownum, userid, name, email, gender
from tbl_member
where userid != 'admin'
and rownum between 4 and 6;


select rno, userid, name, email, gender
from
(
    select rownum as RNO, userid, name, email, gender
    from 
    (
        select userid, name, email, gender
        from tbl_member
        where userid != 'admin'
        order by registerday desc
    ) V
) T
where T.rno between 1 and 3; -- 1페이지 (한페이지당 3개를 보여줄 때)
/*
    currentShowPageNo ==> 1
    sizePerPage       ==> 3
    
    (currentShowPageNo * sizePerPage) - (sizePerPage - 1) ==> 1
    (currentShowPageNo * sizePerPage) ==> 3

*/

select rno, userid, name, email, gender
from
(
    select rownum as RNO, userid, name, email, gender
    from 
    (
        select userid, name, email, gender
        from tbl_member
        where userid != 'admin'
        order by registerday desc
    ) V
) T
where T.rno between 4 and 6; -- 2페이지 (한페이지당 3개를 보여줄 때)
/*
    currentShowPageNo ==> 2
    sizePerPage       ==> 3
    
    (currentShowPageNo * sizePerPage) - (sizePerPage - 1) ==> 4
    (currentShowPageNo * sizePerPage) ==> 6

*/


select rno, userid, name, email, gender
from
(
    select rownum as RNO, userid, name, email, gender
    from 
    (
        select userid, name, email, gender
        from tbl_member
        where userid != 'admin'
        order by registerday desc
    ) V
) T
where T.rno between 7 and 9; -- 3페이지 (한페이지당 3개를 보여줄 때)

/*
    currentShowPageNo ==> 3
    sizePerPage       ==> 3
    
    (currentShowPageNo * sizePerPage) - (sizePerPage - 1) ==> 7
    (currentShowPageNo * sizePerPage) ==> 9

*/

--- *** 검색어가 있는 경우 *** ---
select rno, userid, name, email, gender
from
(
    select rownum as RNO, userid, name, email, gender
    from 
    (
        select userid, name, email, gender
        from tbl_member
        where userid != 'admin'
        and name like '%'|| '승의' ||'%'
        order by registerday desc
    ) V
) T
where T.rno between 1 and 3; -- 1페이지 (한페이지당 3개를 보여줄 때)
/*
    currentShowPageNo ==> 1
    sizePerPage       ==> 3
    
    (currentShowPageNo * sizePerPage) - (sizePerPage - 1) ==> 1
    (currentShowPageNo * sizePerPage) ==> 3

*/

select rno, userid, name, email, gender
from
(
    select rownum as RNO, userid, name, email, gender
    from 
    (
        select userid, name, email, gender
        from tbl_member
        where userid != 'admin'
        and name like '%'|| '승의' ||'%'
        order by registerday desc
    ) V
) T
where T.rno between 4 and 6; -- 2페이지 (한페이지당 3개를 보여줄 때)
/*
    currentShowPageNo ==> 2
    sizePerPage       ==> 3
    
    (currentShowPageNo * sizePerPage) - (sizePerPage - 1) ==> 4
    (currentShowPageNo * sizePerPage) ==> 6

*/


select rno, userid, name, email, gender
from
(
    select rownum as RNO, userid, name, email, gender
    from 
    (
        select userid, name, email, gender
        from tbl_member
        where userid != 'admin'
        and name like '%'|| '승의' ||'%'
        order by registerday desc
    ) V
) T
where T.rno between 7 and 9; -- 3페이지 (한페이지당 3개를 보여줄 때)

/*
    currentShowPageNo ==> 3
    sizePerPage       ==> 3
    
    (currentShowPageNo * sizePerPage) - (sizePerPage - 1) ==> 7
    (currentShowPageNo * sizePerPage) ==> 9

*/

String sql = "select rno, userid, name, email, gender\n"+
"from\n"+
"(\n"+
"    select rownum as RNO, userid, name, email, gender\n"+
"    from \n"+
"    (\n"+
"        select userid, name, email, gender\n"+
"        from tbl_member\n"+
"        where userid != 'admin'\n"+
"        and name like '%'|| '승의' ||'%'\n"+
"        order by registerday desc\n"+
"    ) V\n"+
") T\n"+
"where T.rno between 1 and 3";

--------------------------------------------------------------------------------
--- 검색이 있는 총회원수 또는 검색이 없는 총회원수를 알아오기 위한 것
SELECT ceil( COUNT(*)/'10' )
FROM tbl_member
WHERE userid != 'admin'
AND NAME LIKE '%'||'홍승의' || '%';

SELECT ceil( COUNT(*)/'10' ), ceil( COUNT(*)/'5' ), ceil( COUNT(*)/'3' )
--              21	                    41              	69
FROM tbl_member
WHERE userid != 'admin'
AND NAME LIKE '%'||'홍승의' || '%';


select userid, name, email, gender
        from tbl_member
        where userid != 'admin'

--------------------------------------------------------------------------------
DELETE FROM tbl_member
WHERE userid = 'iyou90';

select * from tbl_member WHERE userid = 'iyou90';

commit;

rollback;


--------------------------------------------------------------------------------
--------------------------------------------------------------------
/*
   카테고리 테이블명 : tbl_category 

   컬럼정의 
     -- 카테고리 대분류 번호  : 시퀀스(seq_category_cnum)로 증가함.(Primary Key)
     -- 카테고리 코드(unique) : ex) 전자제품  '100000'
                                  의류      '200000'
                                  도서      '300000' 
     -- 카테고리명(not null)  : 전자제품, 의류, 도서           
  
*/ 
-- drop table tbl_category purge; 
create table tbl_category
(cnum    number(8)     not null  -- 카테고리 대분류 번호
,code    varchar2(20)  not null  -- 카테고리 코드
,cname   varchar2(100) not null  -- 카테고리명
,constraint PK_tbl_category_cnum primary key(cnum)
,constraint UQ_tbl_category_code unique(code)
);

-- drop sequence seq_category_cnum;
create sequence seq_category_cnum 
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

insert into tbl_category(cnum, code, cname) values(seq_category_cnum.nextval, '100000', '전자제품');
insert into tbl_category(cnum, code, cname) values(seq_category_cnum.nextval, '200000', '의류');
insert into tbl_category(cnum, code, cname) values(seq_category_cnum.nextval, '300000', '도서');
commit;

-- 나중에 넣습니다.
--insert into tbl_category(cnum, code, cname) values(seq_category_cnum.nextval, '400000', '식품');
--commit;

-- insert into tbl_category(cnum, code, cname) values(seq_category_cnum.nextval, '500000', '신발');
-- commit;

/*
delete from tbl_category
where code = '500000';

commit;
*/

select cnum, code, cname
from tbl_category
order by cnum asc;

-- drop table tbl_spec purge;
create table tbl_spec
(snum    number(8)     not null  -- 스펙번호       
,sname   varchar2(100) not null  -- 스펙명         
,constraint PK_tbl_spec_snum primary key(snum)
,constraint UQ_tbl_spec_sname unique(sname)
);

-- drop sequence seq_spec_snum;
create sequence seq_spec_snum
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

insert into tbl_spec(snum, sname) values(seq_spec_snum.nextval, 'HIT');
insert into tbl_spec(snum, sname) values(seq_spec_snum.nextval, 'NEW');
insert into tbl_spec(snum, sname) values(seq_spec_snum.nextval, 'BEST');

commit;

select snum, sname
from tbl_spec
order by snum asc;


---- *** 제품 테이블 : tbl_product *** ----
-- drop table tbl_product purge; 
create table tbl_product
(pnum           number(8) not null       -- 제품번호(Primary Key)
,pname          varchar2(100) not null   -- 제품명
,fk_cnum        number(8)                -- 카테고리코드(Foreign Key)의 시퀀스번호 참조
,pcompany       varchar2(50)             -- 제조회사명
,pimage1        varchar2(100) default 'noimage.png' -- 제품이미지1   이미지파일명
,pimage2        varchar2(100) default 'noimage.png' -- 제품이미지2   이미지파일명 
,pqty           number(8) default 0      -- 제품 재고량
,price          number(8) default 0      -- 제품 정가
,saleprice      number(8) default 0      -- 제품 판매가(할인해서 팔 것이므로)
,fk_snum        number(8)                -- 'HIT', 'NEW', 'BEST' 에 대한 스펙번호인 시퀀스번호를 참조
,pcontent       varchar2(4000)           -- 제품설명  varchar2는 varchar2(4000) 최대값이므로
                                         --          4000 byte 를 초과하는 경우 clob 를 사용한다.
                                         --          clob 는 최대 4GB 까지 지원한다.
                                         
,point          number(8) default 0      -- 포인트 점수                                         
,pinputdate     date default sysdate     -- 제품입고일자
,constraint  PK_tbl_product_pnum primary key(pnum)
,constraint  FK_tbl_product_fk_cnum foreign key(fk_cnum) references tbl_category(cnum)
,constraint  FK_tbl_product_fk_snum foreign key(fk_snum) references tbl_spec(snum)
);

-- drop sequence seq_tbl_product_pnum;
create sequence seq_tbl_product_pnum
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

-- 아래는 fk_snum 컬럼의 값이 1 인 'HIT' 상품만 입력한 것임. 
insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '스마트TV', 1, '삼성', 'tv_samsung_h450_1.png','tv_samsung_h450_2.png', 100,1200000,800000, 1,'42인치 스마트 TV. 기능 짱!!', 50);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북', 1, '엘지', 'notebook_lg_gt50k_1.png','notebook_lg_gt50k_2.png', 150,900000,750000, 1,'노트북. 기능 짱!!', 30);  

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '바지', 2, 'S사', 'cloth_canmart_1.png','cloth_canmart_2.png', 20,12000,10000, 1,'예뻐요!!', 5);       

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '남방', 2, '버카루', 'cloth_buckaroo_1.png','cloth_buckaroo_2.png', 50,15000,13000, 1,'멋져요!!', 10);       
       
insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '세계탐험보물찾기시리즈', 3, '아이세움', 'book_bomul_1.png','book_bomul_2.png', 100,35000,33000, 1,'만화로 보는 세계여행', 20);       
       
insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '만화한국사', 3, '녹색지팡이', 'book_koreahistory_1.png','book_koreahistory_2.png', 80,130000,120000, 1,'만화로 보는 이야기 한국사 전집', 60);
       
commit;


-- 아래는 fk_cnum 컬럼의 값이 1 인 '전자제품' 중 fk_snum 컬럼의 값이 1 인 'HIT' 상품만 입력한 것임. 
insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북1', 1, 'DELL', '1.jpg','2.jpg', 100,1200000,1000000,1,'1번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북2', 1, '에이서','3.jpg','4.jpg',100,1200000,1000000,1,'2번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북3', 1, 'LG전자','5.jpg','6.jpg',100,1200000,1000000,1,'3번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북4', 1, '레노버','7.jpg','8.jpg',100,1200000,1000000,1,'4번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북5', 1, '삼성전자','9.jpg','10.jpg',100,1200000,1000000,1,'5번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북6', 1, 'HP','11.jpg','12.jpg',100,1200000,1000000,1,'6번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북7', 1, '레노버','13.jpg','14.jpg',100,1200000,1000000,1,'7번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북8', 1, 'LG전자','15.jpg','16.jpg',100,1200000,1000000,1,'8번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북9', 1, '한성컴퓨터','17.jpg','18.jpg',100,1200000,1000000,1,'9번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북10', 1, 'MSI','19.jpg','20.jpg',100,1200000,1000000,1,'10번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북11', 1, 'LG전자','21.jpg','22.jpg',100,1200000,1000000,1,'11번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북12', 1, 'HP','23.jpg','24.jpg',100,1200000,1000000,1,'12번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북13', 1, '레노버','25.jpg','26.jpg',100,1200000,1000000,1,'13번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북14', 1, '레노버','27.jpg','28.jpg',100,1200000,1000000,1,'14번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북15', 1, '한성컴퓨터','29.jpg','30.jpg',100,1200000,1000000,1,'15번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북16', 1, '한성컴퓨터','31.jpg','32.jpg',100,1200000,1000000,1,'16번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북17', 1, '레노버','33.jpg','34.jpg',100,1200000,1000000,1,'17번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북18', 1, '레노버','35.jpg','36.jpg',100,1200000,1000000,1,'18번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북19', 1, 'LG전자','37.jpg','38.jpg',100,1200000,1000000,1,'19번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북20', 1, 'LG전자','39.jpg','40.jpg',100,1200000,1000000,1,'20번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북21', 1, '한성컴퓨터','41.jpg','42.jpg',100,1200000,1000000,1,'21번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북22', 1, '에이서','43.jpg','44.jpg',100,1200000,1000000,1,'22번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북23', 1, 'DELL','45.jpg','46.jpg',100,1200000,1000000,1,'23번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북24', 1, '한성컴퓨터','47.jpg','48.jpg',100,1200000,1000000,1,'24번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북25', 1, '삼성전자','49.jpg','50.jpg',100,1200000,1000000,1,'25번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북26', 1, 'MSI','51.jpg','52.jpg',100,1200000,1000000,1,'26번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북27', 1, '애플','53.jpg','54.jpg',100,1200000,1000000,1,'27번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북28', 1, '아수스','55.jpg','56.jpg',100,1200000,1000000,1,'28번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북29', 1, '레노버','57.jpg','58.jpg',100,1200000,1000000,1,'29번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북30', 1, '삼성전자','59.jpg','60.jpg',100,1200000,1000000,1,'30번 노트북', 60);

commit;


-- 아래는 fk_cnum 컬럼의 값이 1 인 '전자제품' 중 fk_snum 컬럼의 값이 2 인 'NEW' 상품만 입력한 것임. 
insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북31', 1, 'MSI','61.jpg','62.jpg',100,1200000,1000000,2,'31번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북32', 1, '삼성전자','63.jpg','64.jpg',100,1200000,1000000,2,'32번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북33', 1, '한성컴퓨터','65.jpg','66.jpg',100,1200000,1000000,2,'33번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북34', 1, 'HP','67.jpg','68.jpg',100,1200000,1000000,2,'34번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북35', 1, 'LG전자','69.jpg','70.jpg',100,1200000,1000000,2,'35번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북36', 1, '한성컴퓨터','71.jpg','72.jpg',100,1200000,1000000,2,'36번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북37', 1, '삼성전자','73.jpg','74.jpg',100,1200000,1000000,2,'37번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북38', 1, '레노버','75.jpg','76.jpg',100,1200000,1000000,2,'38번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북39', 1, 'MSI','77.jpg','78.jpg',100,1200000,1000000,2,'39번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북40', 1, '레노버','79.jpg','80.jpg',100,1200000,1000000,2,'40번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북41', 1, '레노버','81.jpg','82.jpg',100,1200000,1000000,2,'41번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북42', 1, '레노버','83.jpg','84.jpg',100,1200000,1000000,2,'42번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북43', 1, 'MSI','85.jpg','86.jpg',100,1200000,1000000,2,'43번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북44', 1, '한성컴퓨터','87.jpg','88.jpg',100,1200000,1000000,2,'44번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북45', 1, '애플','89.jpg','90.jpg',100,1200000,1000000,2,'45번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북46', 1, '아수스','91.jpg','92.jpg',100,1200000,1000000,2,'46번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북47', 1, '삼성전자','93.jpg','94.jpg',100,1200000,1000000,2,'47번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북48', 1, 'LG전자','95.jpg','96.jpg',100,1200000,1000000,2,'48번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북49', 1, '한성컴퓨터','97.jpg','98.jpg',100,1200000,1000000,2,'49번 노트북', 60);

insert into tbl_product(pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point)
values(seq_tbl_product_pnum.nextval, '노트북50', 1, '레노버','99.jpg','100.jpg',100,1200000,1000000,2,'50번 노트북', 60);

commit;        

-----------------------------------------------------------------------------------------------------------------------        
-- HIT 상품의 전체개수를 알아온다.
SELECT count(*)
FROM tbl_product
WHERE fk_snum = 1; -- 36

SELECT count(*)
FROM tbl_product
WHERE fk_snum = (SELECT snum FROM tbl_spec WHERE sname = 'HIT'); -- 36




select cnum, code, cname
from tbl_category
order by cnum asc;


select snum, sname
from tbl_spec
order by snum asc;

select pnum, pname, code, pcompany, pimage1, pimage2, pqty, price, saleprice, sname, pcontent, point, pinputdate
from 
(
 select row_number() over(order by pnum asc) AS RNO 
      , pnum, pname, C.code, pcompany, pimage1, pimage2, pqty, price, saleprice, S.sname, pcontent, point  
      , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate 
 from tbl_product P 
 JOIN tbl_category C 
 ON P.fk_cnum = C.cnum 
 JOIN tbl_spec S 
 ON P.fk_snum = S.snum
 where S.sname = 'HIT'
) V
where RNO between 1 and 8;


select pnum, pname, code, pcompany, pimage1, pimage2, pqty, price, saleprice, sname, pcontent, point, pinputdate
from 
(
 select row_number() over(order by pnum asc) AS RNO 
      , pnum, pname, C.code, pcompany, pimage1, pimage2, pqty, price, saleprice, S.sname, pcontent, point  
      , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate 
 from tbl_product P 
 JOIN tbl_category C 
 ON P.fk_cnum = C.cnum 
 JOIN tbl_spec S 
 ON P.fk_snum = S.snum
 where S.sname = 'HIT'
) V
where RNO between 9 and 16;


select pnum, pname, code, pcompany, pimage1, pimage2, pqty, price, saleprice, sname, pcontent, point, pinputdate
from 
(
 select row_number() over(order by pnum asc) AS RNO 
      , pnum, pname, C.code, pcompany, pimage1, pimage2, pqty, price, saleprice, S.sname, pcontent, point  
      , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate 
 from tbl_product P 
 JOIN tbl_category C 
 ON P.fk_cnum = C.cnum 
 JOIN tbl_spec S 
 ON P.fk_snum = S.snum
 where S.sname = 'HIT'
) V
where RNO between 17 and 24;    

select pnum, pname, code, pcompany, pimage1, pimage2, pqty, price, saleprice, sname, pcontent, point, pinputdate
from 
(
 select row_number() over(order by pnum asc) AS RNO 
      , pnum, pname, C.code, pcompany, pimage1, pimage2, pqty, price, saleprice, S.sname, pcontent, point  
      , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate 
 from tbl_product P 
 JOIN tbl_category C 
 ON P.fk_cnum = C.cnum 
 JOIN tbl_spec S 
 ON P.fk_snum = S.snum
 where S.sname = 'HIT'
) V
where RNO between 25 and 32; 

select pnum, pname, code, pcompany, pimage1, pimage2, pqty, price, saleprice, sname, pcontent, point, pinputdate
from 
(
 select row_number() over(order by pnum asc) AS RNO 
      , pnum, pname, C.code, pcompany, pimage1, pimage2, pqty, price, saleprice, S.sname, pcontent, point  
      , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate 
 from tbl_product P 
 JOIN tbl_category C 
 ON P.fk_cnum = C.cnum 
 JOIN tbl_spec S 
 ON P.fk_snum = S.snum
 where S.sname = 'HIT'
) V
where RNO between 33 and 40;  
        
        
----- >>> 하나의 제품속에 여러개의 이미지 파일 넣어주기 <<< ------ 
select *
from tbl_product
order by pnum;  

create table tbl_product_imagefile
(imgfileno     number         not null   -- 시퀀스로 입력받음.
,fk_pnum       number(8)      not null   -- 제품번호(foreign key)
,imgfilename   varchar2(100)  not null   -- 제품이미지파일명
,constraint PK_tbl_product_imagefile primary key(imgfileno)
,constraint FK_tbl_product_imagefile foreign key(fk_pnum) references tbl_product(pnum)
);


create sequence seqImgfileno
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select imgfileno, fk_pnum, imgfilename
from tbl_product_imagefile
order by imgfileno desc;

delete from tbl_product_imagefile;

select C.cname, pnum, pname, fk_cnum, pcompany, pimage1, pimage2, pqty, price, saleprice, fk_snum, pcontent, point 
	 , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate
from tbl_category C left join tbl_product P  
on C.cnum = P.fk_cnum  
where C.code = '400000' 
order by pnum desc;       

select * 
from tbl_product
order by pnum desc;

select seq_tbl_product_pnum.nextval 
from dual; -- 채번해오기

delete from tbl_product 
where pnum = 58;

commit;

update tbl_product set pcontent = '<script>alert("우하하하\n누구게??"); getElementsByName('body').style.backgroundColor='red';</script>'
where pnum = 61;


-------- **** 상품구매 후기 테이블 생성하기 **** ----------
create table tbl_purchase_reviews
(review_seq          number 
,fk_userid           varchar2(20)   not null   --  사용자ID       
,fk_pnum             number(8)      not null   -- 제품번호(foreign key)
,contents            varchar2(4000) not null
,writeDate           date default sysdate
,constraint PK_purchase_reviews primary key(review_seq)
,constraint FK_purchase_reviews_userid foreign key(fk_userid) references tbl_member(userid)
,constraint FK_purchase_reviews_pnum foreign key(fk_pnum) references tbl_product(pnum)
);

create sequence seq_purchase_reviews
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select *
from tbl_purchase_reviews
order by review_seq desc;


select review_seq, name, fk_pnum, contents, to_char(writeDate, 'yyyy-mm-dd hh24:mi:ss') AS writeDate
from tbl_purchase_reviews R join tbl_member M
on R.fk_userid = M.userid 
where R.fk_pnum = 3
order by review_seq desc; 

DESC tbl_member;
DESC tbl_product;
----- *** 좋아요, 싫어요 (투표) 테이블 생성하기 *** -----
CREATE TABLE tbl_product_like(
    fk_userid   VARCHAR2(20) NOT NULL,
    fk_pnum     NUMBER(8) NOT NULL,
    CONSTRAINT PK_tbl_product_like PRIMARY KEY(fk_userid, fk_pnum),
    CONSTRAINT fk_tbl_product_like_userid FOREIGN KEY(fk_userid) REFERENCES tbl_member(userid),
    CONSTRAINT fk_tbl_product_like_pnum FOREIGN KEY(fk_pnum) REFERENCES tbl_product(pnum)
);

CREATE TABLE tbl_product_dislike(
    fk_userid   VARCHAR2(20) NOT NULL,
    fk_pnum     NUMBER(8) NOT NULL,
    CONSTRAINT PK_tbl_product_dislike PRIMARY KEY(fk_userid, fk_pnum),
    CONSTRAINT fk_tbl_product_dislike_userid FOREIGN KEY(fk_userid) REFERENCES tbl_member(userid),
    CONSTRAINT fk_tbl_product_dislike_pnum FOREIGN KEY(fk_pnum) REFERENCES tbl_product(pnum)
);
-----------------------------------------------------------------------------------------------
--- sist 이라는 사용자가 제품번호 56 제품을 좋아한다에 투표를 한다. 
--- 먼저 sist 이라는 사용자가 제품번호 56 제품을 싫어한다에 투표를 했을수도 있다.
--- 그러므로 먼저 tbl_product_dislike 테이블에서 sist 사용자와 56번 제품이 insert 되어진 것을 delete해야 한다.

DELETE FROM tbl_product_dislike WHERE fk_userid = 'sist' AND fk_pnum = 56;

INSERT INTO tbl_product_like(fk_userid, fk_pnum) VALUES('sist', 56);
commit;

--- sist 이라는 사용자가 제품번호 56 제품을 싫어한다에 투표를 한다.
--- 먼저 sist 이라는 사용자가 제품번호 56 제품을 좋아한다에 투표를 했을수도 있다.
--- 그러므로 먼저 tbl_product_like 테이블에서 sist 사용자와 56번 제품이 insert 되어진 것을 delete해야 한다.

DELETE FROM tbl_product_like WHERE fk_userid = 'sist' AND fk_pnum = 56;

INSERT INTO tbl_product_dislike(fk_userid, fk_pnum) VALUES('sist', 56);
commit;

rollback;

select *
from tbl_product_like;

select *
from tbl_product_dislike;

---------------------------------------------------------------------------

SELECT count(*)
FROM tbl_product_like
WHERE fk_pnum = 56;

SELECT count(*)
FROM tbl_product_dislike
WHERE fk_pnum = 56;


SELECT count(*)
FROM tbl_product_like
WHERE fk_pnum = 56

SELECT (SELECT count(*)
        FROM tbl_product_like
        WHERE fk_pnum = 56) AS likecnt
      ,(SELECT count(*)
        FROM tbl_product_dislike
        WHERE fk_pnum = 56) AS dislikecnt 
FROM dual;


String sql = "SELECT (SELECT count(*)\n"+
"        FROM tbl_product_like\n"+
"        WHERE fk_pnum = 56) AS likecnt\n"+
"      ,(SELECT count(*)\n"+
"        FROM tbl_product_dislike\n"+
"        WHERE fk_pnum = 56) AS dislikecnt \n"+
"FROM dual";


---- *** 특정 카테고리에 속하는 제품들을 조회(select)해오기 *** ----  
select cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
from 
(
    select rownum AS RNO, cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
    from 
    (
        select C.cname, S.sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
        from 
            (select pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point  
                  , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate, fk_cnum, fk_snum   
             from tbl_product  
             where fk_cnum = 1 
             order by pnum desc
        ) P 
        JOIN tbl_category C 
        ON P.fk_cnum = C.cnum 
        JOIN tbl_spec S 
        ON P.fk_snum = S.snum 
    ) V 
) T 
where T.RNO between 1 and 10;  -- 1페이지 


select cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
from 
(
    select rownum AS RNO, cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
    from 
    (
        select C.cname, S.sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
        from 
            (select pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point  
                  , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate, fk_cnum, fk_snum   
             from tbl_product  
             where fk_cnum = 1 
             order by pnum desc
        ) P 
        JOIN tbl_category C 
        ON P.fk_cnum = C.cnum 
        JOIN tbl_spec S 
        ON P.fk_snum = S.snum 
    ) V 
) T 
where T.RNO between 11 and 20;  -- 2페이지 


select cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
from 
(
    select rownum AS RNO, cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
    from 
    (
        select C.cname, S.sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
        from 
            (select pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point  
                  , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate, fk_cnum, fk_snum   
             from tbl_product  
             where fk_cnum = 1 
             order by pnum desc
        ) P 
        JOIN tbl_category C 
        ON P.fk_cnum = C.cnum 
        JOIN tbl_spec S 
        ON P.fk_snum = S.snum 
    ) V 
) T 
where T.RNO between 21 and 30;  -- 3페이지 


select cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
from 
(
    select rownum AS RNO, cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
    from 
    (
        select C.cname, S.sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
        from 
            (select pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point  
                  , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate, fk_cnum, fk_snum   
             from tbl_product  
             where fk_cnum = 1 
             order by pnum desc
        ) P 
        JOIN tbl_category C 
        ON P.fk_cnum = C.cnum 
        JOIN tbl_spec S 
        ON P.fk_snum = S.snum 
    ) V 
) T 
where T.RNO between 31 and 40;  -- 4페이지 


select cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
from 
(
    select rownum AS RNO, cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
    from 
    (
        select C.cname, S.sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
        from 
            (select pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point  
                  , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate, fk_cnum, fk_snum   
             from tbl_product  
             where fk_cnum = 1 
             order by pnum desc
        ) P 
        JOIN tbl_category C 
        ON P.fk_cnum = C.cnum 
        JOIN tbl_spec S 
        ON P.fk_snum = S.snum 
    ) V 
) T 
where T.RNO between 41 and 50;  -- 5페이지 


select cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
from 
(
    select rownum AS RNO, cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
    from 
    (
        select C.cname, S.sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate 
        from 
            (select pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point  
                  , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate, fk_cnum, fk_snum   
             from tbl_product  
             where fk_cnum = 1 
             order by pnum desc
        ) P 
        JOIN tbl_category C 
        ON P.fk_cnum = C.cnum 
        JOIN tbl_spec S 
        ON P.fk_snum = S.snum 
    ) V 
) T 
where T.RNO between 51 and 60;  -- 6페이지 



String sql = "select cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate \n"+
"from \n"+
"(\n"+
"    select rownum AS RNO, cname, sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate \n"+
"    from \n"+
"    (\n"+
"        select C.cname, S.sname, pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point, pinputdate \n"+
"        from \n"+
"            (select pnum, pname, pcompany, pimage1, pimage2, pqty, price, saleprice, pcontent, point  \n"+
"                  , to_char(pinputdate, 'yyyy-mm-dd') as pinputdate, fk_cnum, fk_snum   \n"+
"             from tbl_product  \n"+
"             where fk_cnum = 1 \n"+
"             order by pnum desc\n"+
"        ) P \n"+
"        JOIN tbl_category C \n"+
"        ON P.fk_cnum = C.cnum \n"+
"        JOIN tbl_spec S \n"+
"        ON P.fk_snum = S.snum \n"+
"    ) V \n"+
") T \n"+
"where T.RNO between 51 and 60";


select imgfilename
from tbl_main_image
		order by imgno desc;




