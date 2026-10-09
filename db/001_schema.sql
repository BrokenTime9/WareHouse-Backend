CREATE TABLE tenants (
    id BIGSERIAL PRIMARY KEY,

    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );


CREATE TABLE warehouses(
  id BIGSERIAL PRIMARY KEY,

  tenant_id BIGINT NOT NULL,

  name VARCHAR(255) NOT NULL,
  code VARCHAR(255) NOT NULL,
  address VARCHAR(255) NOT NULL,

  CONSTRAINT fk_warehouse_tenant
      FOREIGN KEY(tenant_id)
      REFERENCES tenants(id)
      ON DELETE CASCADE
);

CREATE INDEX idx_warehouses_tenant_id 
  ON warehouses(tenant_id);


CREATE TABLE floors (
  id BIGSERIAL PRIMARY KEY,

  tenant_id BIGINT NOT NULL,
  warehouse_id BIGINT NOT NULL,

  name VARCHAR(255) NOT NULL,
  code VARCHAR(255) NOT NULL,


  level INTEGER NOT NULL,

  CONSTRAINT fk_floors_tenant
    FOREIGN KEY(tenant_id) 
    REFERENCES tenants(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_floors_warehouse
    FOREIGN KEY(warehouse_id) 
    REFERENCES warehouses(id)
    ON DELETE CASCADE,

  CONSTRAINT uq_floors_warehouse_level
    UNIQUE(warehouse_id,level)

);

CREATE INDEX idx_floors_tenant_id
  ON floors(tenant_id);

CREATE TABLE rooms(
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  floor_id BIGINT NOT NULL,


  name VARCHAR(255) NOT NULL,
  code VARCHAR(255) NOT NULL,

  x DOUBLE PRECISION NOT NULL,
  z DOUBLE PRECISION NOT NULL,


  w DOUBLE PRECISION NOT NULL,
  d DOUBLE PRECISION NOT NULL,

  type VARCHAR(50) NOT NULL,

  CONSTRAINT fk_rooms_tenant
    FOREIGN KEY(tenant_id) 
    REFERENCES tenants(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_rooms_floor
    FOREIGN KEY(floor_id) 
    REFERENCES floors(id)
    ON DELETE CASCADE,

  CONSTRAINT chk_rooms_size_positive
    CHECK(w > 0 AND d > 0),

  CONSTRAINT chk_rooms_type
    CHECK(
      type IN(
        'storage',
        'office',
        'loading',
        'packing',
        'production',
        'stairs',
        'entrance',
        'elevator',
        'corridor',
        'other'
    )
)
);

CREATE INDEX idx_rooms_tenant_id
  ON rooms(tenant_id);

CREATE INDEX idx_rooms_floor_id
  ON rooms(floor_id);

CREATE TABLE room_links(
  room_a BIGINT NOT NULL,
  room_b BIGINT NOT NULL,
  
  tenant_id BIGINT NOT NULL,


  PRIMARY KEY (room_a, room_b),

  CONSTRAINT fk_room_links_tenant 
    FOREIGN KEY (tenant_id)
    REFERENCES tenants(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_room_links_rooms_A
    FOREIGN KEY (room_a)
    REFERENCES rooms(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_room_links_room_B
    FOREIGN KEY(room_b) 
    REFERENCES rooms(id) 
    ON DELETE CASCADE,

  CONSTRAINT chk_room_links_order
    CHECK (room_a < room_b)
);

CREATE INDEX idx_room_links_room_b
  ON room_links(room_b);

CREATE INDEX idx_room_links_tenant_id
  ON room_links(tenant_id);


CREATE TABLE shelves(
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  room_id BIGINT NOT NULL,

  name VARCHAR(255) NOT NULL,
  

  CONSTRAINT fk_shelves_tenant 
    FOREIGN KEY (tenant_id)
    REFERENCES tenants(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_shelves_room
    FOREIGN KEY (room_id)
    REFERENCES rooms(id)
    ON DELETE CASCADE
);

CREATE INDEX idx_shelves_room_id
  ON shelves(room_id);

CREATE TABLE items(
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  shelf_id BIGINT NOT NULL,

  name VARCHAR(255) NOT NULL,
  sku VARCHAR(100) NOT NULL,
  qty INTEGER NOT NULL DEFAULT 0,

  CONSTRAINT fk_items_tenant
    FOREIGN KEY(tenant_id) 
    REFERENCES tenants(id) 
    ON DELETE CASCADE,

  CONSTRAINT fk_items_shelf
    FOREIGN KEY(shelf_id)
    REFERENCES shelves(id)
    ON DELETE CASCADE,

  CONSTRAINT chk_items_qty
    CHECK(qty >= 0),

  CONSTRAINT uq_items_shelf_sku
    UNIQUE(shelf_id,sku)
);

CREATE INDEX idx_items_tenant_id
  ON items(tenant_id);

CREATE INDEX idx_items_shelf_id
 ON items(shelf_id);
