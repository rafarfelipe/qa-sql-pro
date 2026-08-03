-- ============================================
-- INSERTS NA TABELA payments (30 pagamentos)
-- ============================================

INSERT INTO public.payments (
    order_id,
    payment_method,
    payment_status,
    amount,
    transaction_id,
    payment_date,
    card_last_digits,
    installments,
    notes,
    created_at
) VALUES
-- Pedido 1 (pending) - PIX
(1, 'pix', 'pending', 503.00, 'PIX-2026-001', '2026-07-01 10:35:00', NULL, 1, 'Aguardando confirmação PIX', '2026-07-01 10:30:00'),

-- Pedido 2 (pending) - Boleto
(2, 'boleto', 'pending', 135.15, 'BOL-2026-002', '2026-07-02 14:20:00', NULL, 1, 'Boleto gerado, vence em 3 dias', '2026-07-02 14:15:00'),

-- Pedido 3 (pending) - Cartão de Crédito
(3, 'credit_card', 'processing', 806.66, 'TXN-2026-003', '2026-07-03 09:50:00', '4580', 3, 'Em análise pelo banco', '2026-07-03 09:45:00'),

-- Pedido 4 (pending) - PIX
(4, 'pix', 'pending', 260.89, 'PIX-2026-004', '2026-07-04 16:25:00', NULL, 1, 'Aguardando pagamento', '2026-07-04 16:20:00'),

-- Pedido 5 (processing) - Cartão de Crédito
(5, 'credit_card', 'processing', 594.23, 'TXN-2026-005', '2026-07-05 11:05:00', '5123', 2, 'Pagamento aprovado parcialmente', '2026-07-05 11:00:00'),

-- Pedido 6 (processing) - PayPal
(6, 'paypal', 'paid', 1351.65, 'PAYPAL-2026-006', '2026-07-06 08:35:00', NULL, 1, 'Pagamento confirmado via PayPal', '2026-07-06 08:30:00'),


-- Pedido 8 (processing) - Cartão de Crédito
(8, 'credit_card', 'paid', 2316.34, 'TXN-2026-008', '2026-07-08 10:20:00', '3891', 6, 'Parcelado em 6x sem juros', '2026-07-08 10:15:00'),

-- Pedido 9 (processing) - PIX
(9, 'pix', 'paid', 704.10, 'PIX-2026-009', '2026-07-09 15:35:00', NULL, 1, 'PIX confirmado', '2026-07-09 15:30:00'),

-- Pedido 10 (shipped) - Cartão de Crédito
(10, 'credit_card', 'paid', 260.57, 'TXN-2026-010', '2026-07-10 09:05:00', '7234', 1, 'Pagamento aprovado', '2026-07-10 09:00:00'),

-- Pedido 11 (shipped) - Cartão de Crédito
(11, 'credit_card', 'paid', 3549.10, 'TXN-2026-011', '2026-07-11 14:25:00', '8976', 10, 'Parcelado em 10x no cartão', '2026-07-11 14:20:00'),

-- Pedido 12 (shipped) - PIX
(12, 'pix', 'paid', 599.87, 'PIX-2026-012', '2026-07-12 11:35:00', NULL, 1, 'Pagamento via PIX confirmado', '2026-07-12 11:30:00'),

-- Pedido 13 (shipped) - Boleto
(13, 'boleto', 'paid', 1280.57, 'BOL-2026-013', '2026-07-13 16:50:00', NULL, 1, 'Boleto pago', '2026-07-13 16:45:00'),

-- Pedido 14 (shipped) - Cartão de Débito
(14, 'debit_card', 'paid', 826.34, 'TXN-2026-014', '2026-07-14 08:20:00', '4567', 1, 'Pagamento aprovado', '2026-07-14 08:15:00'),

-- Pedido 15 (shipped) - PayPal
(15, 'paypal', 'paid', 483.68, 'PAYPAL-2026-015', '2026-07-15 13:05:00', NULL, 1, 'Pagamento PayPal confirmado', '2026-07-15 13:00:00'),

-- Pedido 16 (delivered) - Cartão de Crédito
(16, 'credit_card', 'paid', 1028.86, 'TXN-2026-016', '2026-07-01 10:05:00', '2345', 3, 'Pagamento aprovado', '2026-07-01 10:00:00'),

-- Pedido 17 (delivered) - Cartão de Crédito
(17, 'credit_card', 'paid', 2414.65, 'TXN-2026-017', '2026-07-02 15:35:00', '6789', 5, 'Parcelado em 5x', '2026-07-02 15:30:00'),

-- Pedido 18 (delivered) - PIX
(18, 'pix', 'paid', 140.80, 'PIX-2026-018', '2026-07-03 08:25:00', NULL, 1, 'PIX confirmado', '2026-07-03 08:20:00'),

-- Pedido 19 (delivered) - Cartão de Crédito
(19, 'credit_card', 'paid', 5759.63, 'TXN-2026-019', '2026-07-04 11:50:00', '3456', 8, 'Parcelado em 8x', '2026-07-04 11:45:00'),

-- Pedido 20 (delivered) - Boleto
(20, 'boleto', 'paid', 371.34, 'BOL-2026-020', '2026-07-05 14:05:00', NULL, 1, 'Boleto quitado', '2026-07-05 14:00:00'),

-- Pedido 21 (delivered) - Cartão de Débito
(21, 'debit_card', 'paid', 2430.70, 'TXN-2026-021', '2026-07-06 09:20:00', '7890', 1, 'Pagamento aprovado', '2026-07-06 09:15:00'),

-- Pedido 22 (delivered) - PayPal
(22, 'paypal', 'paid', 830.29, 'PAYPAL-2026-022', '2026-07-07 16:35:00', NULL, 1, 'PayPal confirmado', '2026-07-07 16:30:00'),

-- Pedido 23 (delivered) - Cartão de Crédito
(23, 'credit_card', 'paid', 4676.87, 'TXN-2026-023', '2026-07-08 10:50:00', '9012', 6, 'Parcelado em 6x', '2026-07-08 10:45:00'),

-- Pedido 24 (delivered) - PIX
(24, 'pix', 'paid', 255.99, 'PIX-2026-024', '2026-07-09 13:20:00', NULL, 1, 'PIX confirmado', '2026-07-09 13:15:00'),

-- Pedido 25 (delivered) - Cartão de Crédito
(25, 'credit_card', 'paid', 12636.34, 'TXN-2026-025', '2026-07-10 07:35:00', '5678', 12, 'Parcelado em 12x', '2026-07-10 07:30:00'),

-- Pedido 26 (cancelled) - Boleto
(26, 'boleto', 'failed', 596.44, 'BOL-2026-026', '2026-07-11 14:05:00', NULL, 1, 'Boleto vencido - pedido cancelado', '2026-07-11 14:00:00'),

-- Pedido 27 (cancelled) - Cartão de Crédito
(27, 'credit_card', 'failed', 2410.70, 'TXN-2026-027', '2026-07-12 09:35:00', '1234', 1, 'Pagamento negado - cartão bloqueado', '2026-07-12 09:30:00'),

-- Pedido 28 (cancelled) - PIX
(28, 'pix', 'failed', 140.86, 'PIX-2026-028', '2026-07-13 16:50:00', NULL, 1, 'PIX não confirmado - pedido cancelado', '2026-07-13 16:45:00'),

-- Pedido 29 (cancelled) - PayPal
(29, 'paypal', 'refunded', 6986.34, 'PAYPAL-2026-029', '2026-07-14 11:25:00', NULL, 1, 'Pagamento estornado - problema no endereço', '2026-07-14 11:20:00'),

-- Pedido 30 (cancelled) - Cartão de Débito
(30, 'debit_card', 'failed', 1036.75, 'TXN-2026-030', '2026-07-15 08:15:00', '8901', 1, 'Saldo insuficiente - pedido cancelado', '2026-07-15 08:10:00');


