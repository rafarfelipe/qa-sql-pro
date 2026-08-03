-- ============================================
-- INSERTS NA TABELA coupons (15 cupons)
-- ============================================

INSERT INTO public.coupons (
    code,
    description,
    discount_type,
    discount_value,
    min_purchase_amount,
    max_discount_amount,
    usage_limit,
    used_count,
    valid_from,
    valid_until,
    is_active,
    created_at
) VALUES



-- 3. Desconto de aniversário
('ANIVERSARIO20', 'Desconto especial de aniversário', 'percentage', 20.00, 0.00, 100.00, 50, 12, '2026-01-01 00:00:00', '2026-12-31 23:59:59', TRUE, '2026-01-01 08:00:00'),

-- 4. Black Friday
('BLACKFRIDAY50', 'Black Friday - 50% de desconto', 'percentage', 50.00, 200.00, 300.00, 500, 312, '2026-11-20 00:00:00', '2026-11-30 23:59:59', TRUE, '2026-11-01 08:00:00'),

-- 5. Natal
('NATAL25', 'Natal - 25% de desconto', 'percentage', 25.00, 150.00, 150.00, 300, 198, '2026-12-01 00:00:00', '2026-12-25 23:59:59', TRUE, '2026-12-01 08:00:00'),

-- 6. Desconto progressivo
('COMPROU15', 'Ganhou 15% de desconto na próxima compra', 'percentage', 15.00, 0.00, 80.00, 100, 45, '2026-01-01 00:00:00', '2026-12-31 23:59:59', TRUE, '2026-01-15 08:00:00'),

-- 7. Primeira compra
('PRIMEIRACOMPRA', 'Desconto para primeira compra', 'fixed', 30.00, 150.00, 30.00, 150, 89, '2026-01-01 00:00:00', '2026-12-31 23:59:59', TRUE, '2026-01-01 08:00:00'),

-- 8. Dia das Mães
('DIADASMAES', 'Dia das Mães - 15% de desconto', 'percentage', 15.00, 100.00, 100.00, 200, 134, '2026-05-01 00:00:00', '2026-05-15 23:59:59', TRUE, '2026-05-01 08:00:00'),

-- 9. Dia dos Namorados
('NAMORADOS', 'Dia dos Namorados - 12% de desconto', 'percentage', 12.00, 80.00, 80.00, 150, 76, '2026-06-01 00:00:00', '2026-06-14 23:59:59', TRUE, '2026-06-01 08:00:00'),

-- 10. Cupom VIP
('VIP30', 'Cupom exclusivo para clientes VIP', 'percentage', 30.00, 0.00, 200.00, 30, 18, '2026-01-01 00:00:00', '2026-12-31 23:59:59', TRUE, '2026-01-01 08:00:00'),

-- 11. Desconto em eletrônicos
('ELETRO15', '15% off em eletrônicos', 'percentage', 15.00, 300.00, 150.00, 100, 42, '2026-01-01 00:00:00', '2026-12-31 23:59:59', TRUE, '2026-01-10 08:00:00'),

-- 12. Cyber Monday
('CYBER40', 'Cyber Monday - 40% de desconto', 'percentage', 40.00, 250.00, 250.00, 400, 267, '2026-11-27 00:00:00', '2026-11-30 23:59:59', TRUE, '2026-11-01 08:00:00'),

-- 13. Desconto acumulado
('ACUMULA10', '10% de desconto para compras acima de R$500', 'percentage', 10.00, 500.00, 100.00, 80, 31, '2026-01-01 00:00:00', '2026-12-31 23:59:59', TRUE, '2026-01-05 08:00:00'),

-- 14. Cashback especial
('CASHBACK5', 'R$5 de desconto em qualquer compra', 'fixed', 5.00, 0.00, 5.00, 1000, 543, '2026-01-01 00:00:00', '2026-12-31 23:59:59', TRUE, '2026-01-01 08:00:00'),

-- 15. Cupom de despedida
('TCHAU10', '10% off para clientes que vão sair', 'percentage', 10.00, 0.00, 50.00, 50, 8, '2026-07-01 00:00:00', '2026-07-31 23:59:59', TRUE, '2026-07-01 08:00:00');




