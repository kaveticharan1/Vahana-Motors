-- Tests for schema v13: sell requests, car paperwork, inspection / documents / video.
-- Run after supabase-stub.sql and schema.sql (see README). Every line says what to expect.
\set ON_ERROR_STOP 0
insert into auth.users(id,email) values
  ('31111111-1111-1111-1111-111111111111','admin13@x.com'),
  ('32222222-2222-2222-2222-222222222222','sales13@x.com'),
  ('33333333-3333-3333-3333-333333333333','buyer13@x.com');
insert into public.team (email, role) values ('admin13@x.com','admin'), ('sales13@x.com','sales');
insert into cars(id,slug,name,year,km,fuel,price) values ('bbbbbbbb-0000-0000-0000-000000000001','swift-13','Maruti Swift',2019,48000,'Petrol',520000);

\echo '--- AS VISITOR (anon) ---'
set role anon;
\echo 'V1 send a sell request (expect INSERT 0 1):'
insert into sell_requests(name,phone,car,year,km,fuel,expected_price,area) values ('Venkat','9848033333','Maruti Swift VDI',2019,48000,'Diesel',520000,'Gajuwaka');
\echo 'V2 fake status listed (expect INSERT ok but status forced to new):'
insert into sell_requests(name,phone,car,status) values ('Fake','9848044444','Honda City','listed');
\echo 'V3 bad phone (expect check error):'
insert into sell_requests(name,phone,car) values ('Bad','12345','Honda City');
\echo 'V4 read sell requests (expect 0):'
select count(*) from sell_requests;
\echo 'V5 same phone, 2 more ok then 4th blocked (expect INSERT, INSERT, sell_too_many_phone):'
insert into sell_requests(name,phone,car) values ('Venkat','9848033333','Car two');
insert into sell_requests(name,phone,car) values ('Venkat','9848033333','Car three');
insert into sell_requests(name,phone,car) values ('Venkat','9848033333','Car four');
\echo 'V6 read paperwork (expect 0):'
select count(*) from car_paperwork;
\echo 'V7 write paperwork (expect RLS error):'
insert into car_paperwork(car_id,items) values ('bbbbbbbb-0000-0000-0000-000000000001','{"token":"2026-11-15"}');
\echo 'V8 read inspection and docs columns of a car (expect 1 row, {} {}):'
select inspection, docs from cars where slug='swift-13';
\echo 'V9 change inspection (expect UPDATE 0):'
update cars set inspection='{"items":{"engine":"ok"}}' where slug='swift-13';
reset role;

\echo '--- AS LOGGED-IN CUSTOMER ---'
set role authenticated; set request.jwt.sub='33333333-3333-3333-3333-333333333333';
\echo 'C1 send own sell request (expect INSERT 0 1):'
insert into sell_requests(name,phone,car) values ('Buyer','9000055555','Hyundai i20');
\echo 'C2 sees only own request (expect 1):'
select count(*) from sell_requests;
\echo 'C3 change own request status (expect UPDATE 0):'
update sell_requests set status='listed' where true;
\echo 'C4 read paperwork (expect 0):'
select count(*) from car_paperwork;
reset role;

\echo '--- AS SALES ---'
set role authenticated; set request.jwt.sub='32222222-2222-2222-2222-222222222222';
\echo 'S1 sees all sell requests (expect 5):'
select count(*) from sell_requests;
\echo 'S2 moves a request forward (expect UPDATE 1):'
update sell_requests set status='called' where car='Maruti Swift VDI';
\echo 'S3 saves paperwork (expect INSERT 0 1):'
insert into car_paperwork(car_id,items) values ('bbbbbbbb-0000-0000-0000-000000000001','{"token":"2026-11-15"}');
\echo 'S4 paperwork stamped with who saved it (expect sales13@x.com):'
select updated_by from car_paperwork;
\echo 'S5 adds an inspection report and video (expect UPDATE 1):'
update cars set inspection='{"items":{"engine":"ok","tyres":"fix"},"notes":"Tyres 40%"}', docs='{"rc":"yes"}', video_url='https://youtube.com/shorts/abcdefghijk' where slug='swift-13';
\echo 'S6 video link that is not https (expect check error):'
update cars set video_url='javascript:alert(1)' where slug='swift-13';
\echo 'S7 inspection that is not an object (expect check error):'
update cars set inspection='[1,2]' where slug='swift-13';
reset role;

\echo '--- BACK AS VISITOR ---'
set role anon;
\echo 'V10 buyers see the inspection (expect engine ok):'
select inspection->'items'->>'engine' from cars where slug='swift-13';
reset role;
