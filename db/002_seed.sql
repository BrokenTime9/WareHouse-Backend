DO $$

DECLARE
 v_t1 BIGINT; v_wh BIGINT; v_f0 BIGINT;
 v_entrance BIGINT; 
 v_corr_a BIGINT;
 v_storage BIGINT;
BEGIN
    INSERT INTO tenants(name) 
    VALUES ('Cerus Logistics') 
    RETURNING id INTO v_t1;

    INSERT INTO warehouses(tenant_id, name, code, address)
    VALUES (v_t1,'Hana-1','H-1','HanaNoUchi')
    RETURNING id INTO v_wh;

    INSERT INTO floors(tenant_id,warehouse_id,name,code,level)
    VALUES(v_t1,v_wh,'GROUND','F0',0)
    RETURNING id INTO v_f0;

    INSERT INTO rooms(tenant_id,floor_id,name,code,x,z,w,d,type)
    VALUES(v_t1,v_f0,'Main Entrance','G-ENT',0,0,8,8,'entrance')
    RETURNING id INTO v_entrance;

    INSERT INTO rooms(tenant_id,floor_id,name,code,x,z,w,d,type)
    VALUES(v_t1,v_f0,'Corridor A','G-CA',9,0,8,8,'corridor')
    RETURNING id INTO v_corr_a;

    INSERT INTO rooms(tenant_id,floor_id,name,code,x,z,w,d,type)
    VALUES(v_t1,v_f0,'Storage','G-S',0,9,8,8,'storage')
    RETURNING id INTO v_storage;

    INSERT INTO room_links(tenant_id,room_a,room_b)
    VALUES(v_t1,LEAST(v_entrance,v_corr_a),GREATEST(v_entrance,v_corr_a));

    INSERT INTO room_links(tenant_id,room_a,room_b)
    VALUES(v_t1,LEAST(v_entrance,v_storage),GREATEST(v_entrance,v_storage));

END $$;
