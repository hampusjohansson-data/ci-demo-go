CREATE TABLE IF NOT EXISTS service_info (
  id serial PRIMARY KEY,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO service_info(name) VALUES ('bootstrap');
