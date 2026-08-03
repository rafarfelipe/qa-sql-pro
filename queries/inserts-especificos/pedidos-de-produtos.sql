-- ============================================
-- INSERTS NA TABELA orders (30 pedidos)
-- ============================================

INSERT INTO orders (
    user_id,
    order_number,
    status,
    subtotal,
    discount_amount,
    shipping_cost,
    tax_amount,
    total_amount,
    coupon_id,
    shipper_id,
    shipping_address_id,
    billing_address_id,
    tracking_number,
    estimated_delivery,
    delivered_at,
    notes,
    created_at
) VALUES
-- 1. PENDING (aguardando pagamento)
('f796cf50-3954-4098-9a7b-060371c2f311', 'ORD-2026-001', 'pending', 459.90, 0.00, 15.50, 27.59, 503.00, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-01 10:30:00'),
('c5f6d016-a32e-4fa6-b698-6885777a1ce2', 'ORD-2026-002', 'pending', 127.50, 10.00, 10.00, 7.65, 135.15, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-02 14:15:00'),
('bdc85a36-f605-43db-9840-fbe2706b2e00', 'ORD-2026-003', 'pending', 789.30, 50.00, 20.00, 47.36, 806.66, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-03 09:45:00'),
('9e01661d-41cf-42a9-8063-72b4b0c02792', 'ORD-2026-004', 'pending', 234.80, 0.00, 12.00, 14.09, 260.89, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-04 16:20:00'),
-- 5-9. PROCESSING (em processamento)
('f4aa913d-f12b-4e61-a367-ed6e70968036', 'ORD-2026-005', 'processing', 567.20, 25.00, 18.00, 34.03, 594.23, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-05 11:00:00'),
('5c47f882-0e6c-4297-9d1c-78b3fcd297f0', 'ORD-2026-006', 'processing', 1345.90, 100.00, 25.00, 80.75, 1351.65, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-06 08:30:00'),
('174d2aed-f2eb-4c3e-9ed0-50cfddd66b2e', 'ORD-2026-007', 'processing', 89.90, 5.00, 8.00, 5.39, 98.29, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-07 13:45:00'),
('cbd40a71-58bd-4285-9467-e33b40976d84', 'ORD-2026-008', 'processing', 2345.60, 200.00, 30.00, 140.74, 2316.34, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-08 10:15:00'),
('55c89a9a-82ed-4a40-87f8-c3ece0a7bd81', 'ORD-2026-009', 'processing', 678.40, 30.00, 15.00, 40.70, 704.10, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-09 15:30:00'),
-- 10-15. SHIPPED (enviado)
('c772a9b7-5c9f-4d25-987d-760c128bbe24', 'ORD-2026-010', 'shipped', 234.50, 0.00, 12.00, 14.07, 260.57, NULL, 1, NULL, NULL, 'BR123456789', '2026-07-20', NULL, NULL, '2026-07-10 09:00:00'),
('a2adf4c2-5ef3-491e-94cc-8c549e0ffbb2', 'ORD-2026-011', 'shipped', 3456.70, 150.00, 35.00, 207.40, 3549.10, NULL, 2, NULL, NULL, 'BR987654321', '2026-07-21', NULL, NULL, '2026-07-11 14:20:00'),
('bb4a460e-160d-42b8-9dff-b3bea863b81d', 'ORD-2026-012', 'shipped', 567.80, 20.00, 18.00, 34.07, 599.87, NULL, 3, NULL, NULL, 'BR456789123', '2026-07-22', NULL, NULL, '2026-07-12 11:30:00'),
('f796cf50-3954-4098-9a7b-060371c2f311', 'ORD-2026-013', 'shipped', 1234.50, 50.00, 22.00, 74.07, 1280.57, NULL, 1, NULL, NULL, 'BR789123456', '2026-07-23', NULL, NULL, '2026-07-13 16:45:00'),
('c5f6d016-a32e-4fa6-b698-6885777a1ce2', 'ORD-2026-014', 'shipped', 789.00, 30.00, 20.00, 47.34, 826.34, NULL, 2, NULL, NULL, 'BR321654987', '2026-07-24', NULL, NULL, '2026-07-14 08:15:00'),
('bdc85a36-f605-43db-9840-fbe2706b2e00', 'ORD-2026-015', 'shipped', 456.30, 15.00, 15.00, 27.38, 483.68, NULL, 1, NULL, NULL, 'BR654987321', '2026-07-25', NULL, NULL, '2026-07-15 13:00:00'),
-- 16-25. DELIVERED (entregue)
('9e01661d-41cf-42a9-8063-72b4b0c02792', 'ORD-2026-016', 'delivered', 987.60, 40.00, 22.00, 59.26, 1028.86, NULL, 3, NULL, NULL, 'BR147258369', '2026-07-10', '2026-07-09 14:30:00', 'Cliente satisfeito com a entrega', '2026-07-01 10:00:00'),
('f4aa913d-f12b-4e61-a367-ed6e70968036', 'ORD-2026-017', 'delivered', 2345.90, 100.00, 28.00, 140.75, 2414.65, NULL, 1, NULL, NULL, 'BR258369147', '2026-07-11', '2026-07-10 11:20:00', NULL, '2026-07-02 15:30:00'),
('5c47f882-0e6c-4297-9d1c-78b3fcd297f0', 'ORD-2026-018', 'delivered', 123.40, 0.00, 10.00, 7.40, 140.80, NULL, 2, NULL, NULL, 'BR369147258', '2026-07-12', '2026-07-11 09:45:00', 'Entrega rápida', '2026-07-03 08:20:00'),
('174d2aed-f2eb-4c3e-9ed0-50cfddd66b2e', 'ORD-2026-019', 'delivered', 5678.90, 300.00, 40.00, 340.73, 5759.63, NULL, 1, NULL, NULL, 'BR741852963', '2026-07-13', '2026-07-12 16:10:00', NULL, '2026-07-04 11:45:00'),
('cbd40a71-58bd-4285-9467-e33b40976d84', 'ORD-2026-020', 'delivered', 345.60, 10.00, 15.00, 20.74, 371.34, NULL, 3, NULL, NULL, 'BR852963741', '2026-07-14', '2026-07-13 10:30:00', 'Produto em perfeito estado', '2026-07-05 14:00:00'),
('55c89a9a-82ed-4a40-87f8-c3ece0a7bd81', 'ORD-2026-021', 'delivered', 2345.00, 80.00, 25.00, 140.70, 2430.70, NULL, 2, NULL, NULL, 'BR963741852', '2026-07-15', '2026-07-14 08:50:00', NULL, '2026-07-06 09:15:00'),
('c772a9b7-5c9f-4d25-987d-760c128bbe24', 'ORD-2026-022', 'delivered', 789.90, 25.00, 18.00, 47.39, 830.29, NULL, 1, NULL, NULL, 'BR159357486', '2026-07-16', '2026-07-15 13:40:00', 'Recomendo!', '2026-07-07 16:30:00'),
('a2adf4c2-5ef3-491e-94cc-8c549e0ffbb2', 'ORD-2026-023', 'delivered', 4567.80, 200.00, 35.00, 274.07, 4676.87, NULL, 2, NULL, NULL, 'BR357486159', '2026-07-17', '2026-07-16 11:25:00', NULL, '2026-07-08 10:45:00'),
('bb4a460e-160d-42b8-9dff-b3bea863b81d', 'ORD-2026-024', 'delivered', 234.90, 5.00, 12.00, 14.09, 255.99, NULL, 3, NULL, NULL, 'BR486159357', '2026-07-18', '2026-07-17 09:30:00', 'Tudo certo', '2026-07-09 13:15:00'),
('f796cf50-3954-4098-9a7b-060371c2f311', 'ORD-2026-025', 'delivered', 12345.60, 500.00, 50.00, 740.74, 12636.34, NULL, 1, NULL, NULL, 'BR753159486', '2026-07-19', '2026-07-18 15:00:00', NULL, '2026-07-10 07:30:00'),
-- 26-30. CANCELLED (cancelado)
('c5f6d016-a32e-4fa6-b698-6885777a1ce2', 'ORD-2026-026', 'cancelled', 567.40, 20.00, 15.00, 34.04, 596.44, NULL, 2, NULL, NULL, NULL, NULL, NULL, 'Cliente desistiu da compra', '2026-07-11 14:00:00'),
('bdc85a36-f605-43db-9840-fbe2706b2e00', 'ORD-2026-027', 'cancelled', 2345.00, 100.00, 25.00, 140.70, 2410.70, NULL, 1, NULL, NULL, NULL, NULL, NULL, 'Pagamento não aprovado', '2026-07-12 09:30:00'),
('9e01661d-41cf-42a9-8063-72b4b0c02792', 'ORD-2026-028', 'cancelled', 123.45, 0.00, 10.00, 7.41, 140.86, NULL, 3, NULL, NULL, NULL, NULL, NULL, 'Solicitado pelo cliente', '2026-07-13 16:45:00'),
('f4aa913d-f12b-4e61-a367-ed6e70968036', 'ORD-2026-029', 'cancelled', 6789.00, 250.00, 40.00, 407.34, 6986.34, NULL, 2, NULL, NULL, NULL, NULL, NULL, 'Problema com o endereço', '2026-07-14 11:20:00'),
('5c47f882-0e6c-4297-9d1c-78b3fcd297f0', 'ORD-2026-030', 'cancelled', 987.50, 30.00, 20.00, 59.25, 1036.75, NULL, 1, NULL, NULL, NULL, NULL, NULL, 'Estoque insuficiente', '2026-07-15 08:10:00');