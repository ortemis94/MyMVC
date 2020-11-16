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








