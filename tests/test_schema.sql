-- No two floors should be on the same level
-- item should be unique on a shelf
-- two skus on two shelves
-- cascading effect

BEGIN;

DO $$
DECLARE
  v_tenant BIGINT;
  v_warehouse BIGINT;
  v_floor BIGINT;
  v_other_floor BIGINT;

  v_room_a BIGINT;
  v_room_b BIGINT;

  v_shelf_a BIGINT;
  v_shelf_b BIGINT;

  v_item_a BIGINT;
  v_item_b BIGINT;

  v_floor_level INTEGER;
  v_item_a_sku VARCHAR(255);
  v_item_b_sku VARCHAR(255);
BEGIN

  INSERT INTO 
    tenants(name)
  VALUES 
    ('Schema test Tenant')
  RETURNING id INTO v_tenant;

  INSERT INTO warehouses
    (tenant_id,name,code,address)
  VALUES
    (v_tenant,'Test Warehouse','TEST-WH','Test Address')
  RETURNING id INTO v_warehouse;

  INSERT INTO floors
    (tenant_id,warehouse_id,name,code,level)
  VALUES
    (v_tenant,v_warehouse,'Test Floor','TF',0)
  RETURNING id,level INTO v_floor,v_floor_level ;

  INSERT INTO rooms
    (tenant_id,floor_id,name,code,x,z,w,d,type)
  VALUES
    (v_tenant,v_floor,'Test Room A','TRA',1,1,1,1,'storage')
  RETURNING id INTO v_room_a;

  INSERT INTO rooms
    (tenant_id,floor_id,name,code,x,z,w,d,type)
  VALUES
    (v_tenant,v_floor,'Test Room B','TRB',1,1,1,1,'storage')
  RETURNING id INTO v_room_b;

  INSERT INTO shelves
    (tenant_id,room_id,name)
  VALUES
    (v_tenant,v_room_a,'Test Shelf A')
  RETURNING id INTO v_shelf_a;

  INSERT INTO shelves
    (tenant_id,room_id,name)
  VALUES
    (v_tenant,v_room_b,'Test Shelf B')
  RETURNING id INTO v_shelf_b;

  INSERT INTO items 
    (tenant_id,shelf_id,name,sku,qty) 
  VALUES 
    (v_tenant,v_shelf_a,'Test item', '01',1)
  RETURNING id,sku INTO v_item_a,v_item_a_sku;

  INSERT INTO items
    (tenant_id,shelf_id,name,sku,qty)
  VALUES
    (v_tenant,v_shelf_b,'Test Item 2','02',1)
  RETURNING id,sku INTO v_item_b,v_item_b_sku;


  -- floor level uniqueness
  BEGIN
      INSERT INTO floors
        (tenant_id,warehouse_id,name,code,level)
      VALUES
        (v_tenant,v_warehouse,'Test Floor','TF',v_floor_level);

      RAISE EXCEPTION
        'FAIL: Two Floors were added in the same level';

  EXCEPTION
      WHEN unique_violation THEN
        RAISE NOTICE 'PASS: Duplicate floor level was rejected';
  END;

  -- item shelf uniqueness

  BEGIN
      INSERT INTO items
        (tenant_id,shelf_id,name,sku,qty)
      VALUES
        (v_tenant,v_shelf_a,'Test item',v_item_b_sku,1);

      RAISE NOTICE
        'PASS: Two items with sku added on different shelves';
  END;

  BEGIN
      INSERT INTO items
        (tenant_id,shelf_id,name,sku,qty)
      VALUES
        (v_tenant,v_shelf_a,'Test Item',v_item_a_sku,1);

      RAISE EXCEPTION
        'FAIL: Duplicate Item added in the same shelf';

  EXCEPTION
      WHEN unique_violation THEN
        RAISE NOTICE 'PASS: Duplicate item on the same shelf was rejected';
  END;

    
  DELETE FROM tenants WHERE id = v_tenant;

  IF EXISTS (SELECT 1 FROM warehouses WHERE id IN (v_warehouse))
    OR EXISTS(SELECT 1 FROM floors WHERE id IN (v_floor))
    OR EXISTS(SELECT 1 FROM rooms WHERE id IN (v_room_a,v_room_b)) 
    OR EXISTS(SELECT 1 FROM shelves WHERE id IN (v_shelf_a,v_shelf_b))
    OR EXISTS(SELECT 1 FROM items WHERE id IN (v_item_a,v_item_b))

  THEN
    RAISE EXCEPTION
      'FAIL: Floor deletion left dependent records behind';

  END IF;

  RAISE NOTICE
    'PASS: tenant deletion cascaded to warehouses,floors,rooms,shelves,items';



END $$;

ROLLBACK;
