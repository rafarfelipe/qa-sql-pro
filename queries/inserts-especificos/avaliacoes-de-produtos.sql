-- ============================================
-- INSERTS NA TABELA reviews (40 avaliações)
-- ============================================

INSERT INTO reviews (
    product_id,
    user_id,
    order_id,
    rating,
    title,
    comment,
    is_verified_purchase,
    is_approved,
    helpful_count,
    created_at
) VALUES
-- Produto 577 (4 avaliações)
( 577, 'c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 16, 5, 'Produto excelente!', 'Superou minhas expectativas. Qualidade impecável e entrega rápida.', true, true, 23, '2026-07-02 10:15:00'),
( 577, '5efbb6a1-3c2e-4f71-8939-a1bcb5e5e7d4', 17, 4, 'Muito bom', 'Produto de ótima qualidade, só o preço que é um pouco salgado.', true, true, 8, '2026-07-05 14:30:00'),
( 577, '5bd86580-4d13-41c5-9597-567cb579a1fa', 18, 5, 'Recomendo demais!', 'Melhor compra que fiz esse mês. Produto veio bem embalado.', true, true, 15, '2026-07-08 09:45:00'),
( 577, '3e71bd1a-2cdf-4d10-a2c2-c602af55c25f', 19, 3, 'Ok, mas podia ser melhor', 'Produto atende ao básico, mas esperava mais pela qualidade.', true, true, 5, '2026-07-10 16:20:00'),
-- Produto 241 (3 avaliações)
( 241, '419eb463-da4d-469a-95fa-27283279490e', 20, 5, 'Perfeito!', 'Exatamente como descrito. Muito satisfeito com a compra.', true, true, 18, '2026-07-03 11:00:00'),
( 241, 'ceb5b92f-8921-4bcd-9ccb-e023d74b774f', 21, 4, 'Bom custo-benefício', 'Produto de qualidade, entrega dentro do prazo.', true, true, 7, '2026-07-06 08:30:00'),
( 241, 'e3cf4301-9ba6-4d82-90c8-cfc81054a202', 22, 5, 'Amei!', 'Já vou comprar outro para presentear. Produto fantástico!', true, true, 31, '2026-07-09 13:15:00'),
-- Produto 829 (3 avaliações)
( 829, '54c6b7ff-a298-4c66-862a-d1a9066f4b98', 23, 4, 'Ótimo produto', 'Funciona perfeitamente, recomendo a todos.', true, true, 12, '2026-07-04 15:45:00'),
( 829, '60972209-626e-4ed6-b567-6000795f7f56', 24, 3, 'Mais ou menos', 'Não é ruim, mas existem opções melhores no mercado.', true, true, 4, '2026-07-07 10:00:00'),
( 829, '14d8954b-5594-4bf1-b9c0-6a6ed9b06f7c', 25, 5, 'Simplesmente incrível!', 'Nunca vi um produto tão bom nessa faixa de preço.', true, true, 27, '2026-07-11 14:30:00'),
-- Produto 239 (3 avaliações)
( 239, 'c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 16, 5, 'Excelente!', 'Produto de altíssima qualidade. Recomendo sem hesitar.', true, true, 19, '2026-07-12 09:20:00'),
( 239, '5efbb6a1-3c2e-4f71-8939-a1bcb5e5e7d4', 17, 4, 'Muito bom mesmo', 'Entrega rápida e produto conforme esperado.', true, true, 6, '2026-07-03 11:30:00'),
( 239, '5bd86580-4d13-41c5-9597-567cb579a1fa', 18, 5, 'Maravilhoso!', 'Superou todas as expectativas, vale cada centavo.', true, true, 14, '2026-07-06 16:00:00'),
-- Produto 247 (3 avaliações)
( 247, '3e71bd1a-2cdf-4d10-a2c2-c602af55c25f', 19, 2, 'Decepcionado', 'Produto veio com defeito, tive que solicitar troca.', true, true, 11, '2026-07-08 10:30:00'),
( 247, '419eb463-da4d-469a-95fa-27283279490e', 20, 4, 'Bom produto', 'Atende bem, mas a embalagem poderia ser melhor.', true, true, 3, '2026-07-13 08:45:00'),
( 247, 'ceb5b92f-8921-4bcd-9ccb-e023d74b774f', 21, 5, 'Recomendo 100%', 'Produto excelente, entrega super rápida!', true, true, 22, '2026-07-02 15:00:00'),
-- Produto 848 (3 avaliações)
( 848, 'e3cf4301-9ba6-4d82-90c8-cfc81054a202', 22, 5, 'Fantástico', 'Melhor produto que já comprei nessa categoria.', true, true, 34, '2026-07-05 13:15:00'),
( 848, '54c6b7ff-a298-4c66-862a-d1a9066f4b98', 23, 4, 'Muito bom', 'Produto de qualidade, entrega dentro do prazo.', true, true, 9, '2026-07-09 11:45:00'),
( 848, '60972209-626e-4ed6-b567-6000795f7f56', 24, 5, 'Simplesmente perfeito!', 'Atendeu 100% do que eu precisava.', true, true, 16, '2026-07-12 14:00:00'),
-- Produto 243 (3 avaliações)
( 243, '14d8954b-5594-4bf1-b9c0-6a6ed9b06f7c', 25, 3, 'Razoável', 'Poderia ser melhor pelo preço cobrado.', true, true, 5, '2026-07-03 09:30:00'),
( 243, 'c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 16, 4, 'Bom produto', 'Atende bem às necessidades, recomendo.', true, true, 7, '2026-07-07 17:00:00'),
( 243, '5efbb6a1-3c2e-4f71-8939-a1bcb5e5e7d4', 17, 5, 'Excelente qualidade', 'Produto durável e de ótimo acabamento.', true, true, 20, '2026-07-11 10:15:00'),
-- Produto 448 (3 avaliações)
( 448, '5bd86580-4d13-41c5-9597-567cb579a1fa', 18, 4, 'Muito bom', 'Produto atende bem, preço justo.', true, true, 8, '2026-07-04 14:45:00'),
( 448, '3e71bd1a-2cdf-4d10-a2c2-c602af55c25f', 19, 5, 'Adorei!', 'Produto veio perfeito, muito bem embalado.', true, true, 13, '2026-07-08 08:30:00'),
( 448, '419eb463-da4d-469a-95fa-27283279490e', 20, 4, 'Ótimo custo-benefício', 'Qualidade excelente pelo valor pago.', true, true, 11, '2026-07-12 16:20:00'),
-- Produto 454 (4 avaliações)
( 454, 'ceb5b92f-8921-4bcd-9ccb-e023d74b774f', 21, 5, 'Perfeito!', 'Exatamente o que eu estava procurando.', true, true, 25, '2026-07-02 11:00:00'),
( 454, 'e3cf4301-9ba6-4d82-90c8-cfc81054a202', 22, 3, 'Mais ou menos', 'Produto ok, mas a entrega demorou.', true, true, 2, '2026-07-06 15:30:00'),
( 454, '54c6b7ff-a298-4c66-862a-d1a9066f4b98', 23, 5, 'Excelente produto!', 'Surpreendido pela qualidade, recomendo a todos.', true, true, 29, '2026-07-10 09:45:00'),
( 454, '60972209-626e-4ed6-b567-6000795f7f56', 24, 4, 'Bom, mas podia ser melhor', 'Produto de qualidade, mas a embalagem veio amassada.', true, true, 6, '2026-07-13 13:00:00'),
-- Produto 486 (3 avaliações)
( 486, '14d8954b-5594-4bf1-b9c0-6a6ed9b06f7c', 25, 5, 'Maravilhoso', 'Melhor compra do ano, produto incrível!', true, true, 37, '2026-07-05 10:30:00'),
( 486, 'c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 16, 4, 'Muito bom', 'Atende perfeitamente, entrega dentro do prazo.', true, true, 10, '2026-07-09 14:15:00'),
( 486, '5efbb6a1-3c2e-4f71-8939-a1bcb5e5e7d4', 17, 2, 'Não gostei', 'Produto não correspondeu às expectativas.', true, true, 4, '2026-07-12 11:30:00'),
-- Produto 245 (3 avaliações)
( 245, '5bd86580-4d13-41c5-9597-567cb579a1fa', 18, 5, 'Sensacional!', 'Produto de alta qualidade, recomendo fortemente.', true, true, 21, '2026-07-03 16:45:00'),
( 245, '3e71bd1a-2cdf-4d10-a2c2-c602af55c25f', 19, 4, 'Ótimo', 'Produto atendeu bem, preço justo.', true, true, 7, '2026-07-07 09:00:00'),
( 245, '419eb463-da4d-469a-95fa-27283279490e', 20, 5, 'Amei esse produto', 'Já comprei outros modelos, esse é o melhor até agora.', true, true, 19, '2026-07-11 15:30:00'),
-- Produto 497 (3 avaliações)
( 497, 'ceb5b92f-8921-4bcd-9ccb-e023d74b774f', 21, 3, 'Regular', 'Produto ok, mas não é nada especial.', true, true, 3, '2026-07-04 13:20:00'),
( 497, 'e3cf4301-9ba6-4d82-90c8-cfc81054a202', 22, 4, 'Bom produto', 'Funciona bem, entrega rápida.', true, true, 8, '2026-07-08 10:45:00'),
( 497, '54c6b7ff-a298-4c66-862a-d1a9066f4b98', 23, 5, 'Excelente!', 'Produto de primeira linha, super recomendo.', true, true, 33, '2026-07-12 08:15:00'),
-- Produto 498 (3 avaliações)
( 498, '60972209-626e-4ed6-b567-6000795f7f56', 24, 4, 'Muito bom', 'Produto atende às necessidades, recomendo.', true, true, 9, '2026-07-06 12:30:00'),
( 498, '14d8954b-5594-4bf1-b9c0-6a6ed9b06f7c', 25, 5, 'Simplesmente incrível!', 'Valeu cada centavo, produto de excelente qualidade.', true, true, 26, '2026-07-10 17:15:00'),
( 498, 'c8f1d05b-4f42-4cca-a2ef-7c522d18888b', 16, 1, 'Péssimo', 'Produto veio quebrado, tive que devolver. Experiência horrível.', true, true, 15, '2026-07-13 09:30:00');