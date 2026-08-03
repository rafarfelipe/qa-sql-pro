DELETE
FROM
    public.addresses
WHERE
    id = 3
    
    
-- TRUNCATE zera a tabela inteira instantaneamente
TRUNCATE TABLE addresses;
-- NÃO RODE ISSO EM PRODUÇÃO SEM CERTEZA ABSOLUTA
-- NÃO RODE ISSO EM PRODUÇÃO SEM CERTEZA ABSOLUTA

-- TRUNCATE zera a tabela inteira instantaneamente
TRUNCATE TABLE addresses CASCADE;
-- NÃO RODE ISSO EM PRODUÇÃO SEM CERTEZA ABSOLUTA

INSERT
    INTO
    public.addresses
(user_id,
    address_type,
    "label",
    street,
    "number",
    complement,
    neighborhood,
    city,
    state,
    zip_code,
    country,
    is_default,
    created_at)
VALUES('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping'::CHARACTER VARYING, '', '', '', '', '', '', '', '', 'Brazil'::CHARACTER VARYING, FALSE, now());





INSERT INTO public.addresses
(user_id, address_type, "label", street, "number", complement, neighborhood, city, state, zip_code, country, is_default, created_at)
VALUES
('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping', 'Casa', 'Rua das Flores', '123', 'Apto 101', 'Centro', 'São Paulo', 'SP', '01001-000', 'Brazil', TRUE, now());


-- TRUNCATE zera a tabela inteira instantaneamente
TRUNCATE TABLE addresses CASCADE;

TRUNCATE TABLE addresses RESTART IDENTITY
CASCADE



INSERT INTO public.addresses
(user_id, address_type, "label", street, "number", complement, neighborhood, city, state, zip_code, country, is_default, created_at)
VALUES
--('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping', 'Casa', 'Rua das Flores', '123', 'Apto 101', 'Centro', 'São Paulo', 'SP', '01001-000', 'Brazil', TRUE, now());
('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping', 'Trabalho', 'Av. Paulista', '1500', 'Sala 45', 'Bela Vista', 'São Paulo', 'SP', '01310-200', 'Brazil', FALSE, now()),
('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping', 'Casa Praia', 'Rua do Sol', '77', 'Casa', 'Praia Grande', 'Santos', 'SP', '11000-000', 'Brazil', FALSE, now()),
('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping', 'Casa Pais', 'Rua Oliveira', '890', '', 'Jardim América', 'Rio de Janeiro', 'RJ', '22000-000', 'Brazil', FALSE, now()),
('c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 'shipping', 'Outro', 'Av. Brasil', '500', 'Bloco B', 'Centro', 'Curitiba', 'PR', '80000-000', 'Brazil', FALSE, now());