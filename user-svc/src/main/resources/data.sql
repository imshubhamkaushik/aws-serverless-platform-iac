INSERT INTO users (name, email, password) VALUES ('Alice', 'alice@example.com', 'alice123') ON CONFLICT DO NOTHING;
INSERT INTO users (name, email, password) VALUES ('Bob', 'bob@example.com', 'bob123') ON CONFLICT DO NOTHING;
INSERT INTO users (name, email, password) VALUES ('Charlie', 'charlie@example.com', 'charlie123') ON CONFLICT DO NOTHING;
INSERT INTO users (name, email, password) VALUES ('Dave', 'dave@example.com', 'dave123') ON CONFLICT DO NOTHING;
INSERT INTO users (name, email, password) VALUES ('Eve', 'eve@example.com', 'eve123') ON CONFLICT DO NOTHING;