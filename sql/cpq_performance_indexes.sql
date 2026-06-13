-- ============================================
-- CPQ 性能优化 — 数据库索引调优（S20.4）
-- 基于执行计划分析，为全部 43+ 张表添加索引
-- 原则：在 WHERE/JOIN/ORDER BY 高频列上建索引
-- ============================================

-- D01 产品数据域 ============================

-- cpq_product_category：按 catalog_id 查询分类
CREATE INDEX IF NOT EXISTS idx_pcat_catalog ON cpq_product_category(catalog_id, del_flag);
CREATE INDEX IF NOT EXISTS idx_pcat_parent ON cpq_product_category(parent_id);

-- cpq_product_catalog：按名称查询
CREATE INDEX IF NOT EXISTS idx_pcatalog_name ON cpq_product_catalog(catalog_name);

-- cpq_product_model：高频查询列
CREATE INDEX IF NOT EXISTS idx_pmodel_catalog ON cpq_product_model(catalog_id);
CREATE INDEX IF NOT EXISTS idx_pmodel_category ON cpq_product_model(category_id);
CREATE INDEX IF NOT EXISTS idx_pmodel_code ON cpq_product_model(model_code);
CREATE INDEX IF NOT EXISTS idx_pmodel_status ON cpq_product_model(status, del_flag);

-- cpq_sbom_header：按产品模型查询
CREATE INDEX IF NOT EXISTS idx_sbom_model ON cpq_sbom_header(model_id, del_flag);
CREATE INDEX IF NOT EXISTS idx_sbom_version ON cpq_sbom_header(bom_version);

-- cpq_sbom_line：按头ID查询行项目
CREATE INDEX IF NOT EXISTS idx_sboml_header ON cpq_sbom_line(header_id);
CREATE INDEX IF NOT EXISTS idx_sboml_item ON cpq_sbom_line(item_id);

-- cpq_mbom_line：按 sbom_line_id 关联
CREATE INDEX IF NOT EXISTS idx_mbom_sbom ON cpq_mbom_line(sbom_line_id);
CREATE INDEX IF NOT EXISTS idx_mbom_plant ON cpq_mbom_line(plant_id);

-- cpq_product_attribute：按模板/模型查询
CREATE INDEX IF NOT EXISTS idx_pattr_model ON cpq_product_attribute(model_id);
CREATE INDEX IF NOT EXISTS idx_pattr_template ON cpq_product_attribute(template_id);

-- cpq_attribute_option：按属性ID + 排序
CREATE INDEX IF NOT EXISTS idx_aopt_attr ON cpq_attribute_option(attribute_id, sort_order);

-- cpq_product_lifecycle：按产品/阶段
CREATE INDEX IF NOT EXISTS idx_plc_product ON cpq_product_lifecycle(product_id, lifecycle_stage);
CREATE INDEX IF NOT EXISTS idx_plc_eff_date ON cpq_product_lifecycle(effective_date);

-- cpq_product_supersession：按旧料号/新料号
CREATE INDEX IF NOT EXISTS idx_psup_old ON cpq_product_supersession(old_item_id);
CREATE INDEX IF NOT EXISTS idx_psup_new ON cpq_product_supersession(new_item_id);
CREATE INDEX IF NOT EXISTS idx_psup_eff ON cpq_product_supersession(effective_date, expiry_date);

-- D02 定价域 ================================

-- cpq_price_book：按类型/状态
CREATE INDEX IF NOT EXISTS idx_pb_type ON cpq_price_book(book_type, status);

-- cpq_price_book_entry：按价格手册 + 产品
CREATE INDEX IF NOT EXISTS idx_pbe_book ON cpq_price_book_entry(book_id);
CREATE INDEX IF NOT EXISTS idx_pbe_product ON cpq_price_book_entry(product_id);

-- cpq_price_rule：按规则类型 + 产品
CREATE INDEX IF NOT EXISTS idx_prule_type ON cpq_price_rule(rule_type, product_id);
CREATE INDEX IF NOT EXISTS idx_prule_priority ON cpq_price_rule(priority);

-- cpq_volume_tier：按产品ID
CREATE INDEX IF NOT EXISTS idx_vtier_product ON cpq_volume_tier(product_id);
CREATE INDEX IF NOT EXISTS idx_vtier_range ON cpq_volume_tier(min_quantity, max_quantity);

-- cpq_channel_price：按渠道+产品
CREATE INDEX IF NOT EXISTS idx_cprice_channel ON cpq_channel_price(channel_id, product_id);

-- cpq_exchange_rate：按货币对+日期
CREATE INDEX IF NOT EXISTS idx_exrate_pair ON cpq_exchange_rate(from_currency, to_currency, effective_date);

-- D03 配置引擎 ==============================

-- cpq_config_rule：按产品模型 + 规则类型
CREATE INDEX IF NOT EXISTS idx_crule_model ON cpq_config_rule(model_id);
CREATE INDEX IF NOT EXISTS idx_crule_type ON cpq_config_rule(rule_type);
CREATE INDEX IF NOT EXISTS idx_crule_eff ON cpq_config_rule(effective_date);

-- cpq_variant_bom：按 config_rule_id
CREATE INDEX IF NOT EXISTS idx_vbom_rule ON cpq_variant_bom(rule_id);

-- cpq_compatibility_matrix：按两个模型ID
CREATE INDEX IF NOT EXISTS idx_cmat_a ON cpq_compatibility_matrix(model_a_id);
CREATE INDEX IF NOT EXISTS idx_cmat_b ON cpq_compatibility_matrix(model_b_id);

-- cpq_attribute_mapping：按来源/目标属性
CREATE INDEX IF NOT EXISTS idx_amap_src ON cpq_attribute_mapping(source_attribute_id);
CREATE INDEX IF NOT EXISTS idx_amap_tgt ON cpq_attribute_mapping(target_attribute_id);

-- cpq_bundle：按名称/状态
CREATE INDEX IF NOT EXISTS idx_bundle_status ON cpq_bundle(status);

-- cpq_bundle_option_group：按 bundle_id
CREATE INDEX IF NOT EXISTS idx_bog_bundle ON cpq_bundle_option_group(bundle_id);

-- cpq_bundle_option：按组ID
CREATE INDEX IF NOT EXISTS idx_bopt_group ON cpq_bundle_option(group_id);

-- D04 报价域 ================================

-- cpq_quote_header：按状态 + 客户
CREATE INDEX IF NOT EXISTS idx_qh_status ON cpq_quote_header(status, del_flag);
CREATE INDEX IF NOT EXISTS idx_qh_account ON cpq_quote_header(account_id);
CREATE INDEX IF NOT EXISTS idx_qh_number ON cpq_quote_header(quote_number);
CREATE INDEX IF NOT EXISTS idx_qh_create ON cpq_quote_header(create_time);

-- cpq_quote_line_item：按报价头ID
CREATE INDEX IF NOT EXISTS idx_qli_header ON cpq_quote_line_item(header_id);
CREATE INDEX IF NOT EXISTS idx_qli_product ON cpq_quote_line_item(product_id);

-- cpq_quote_config_snapshot：按行项目
CREATE INDEX IF NOT EXISTS idx_qsnap_line ON cpq_quote_config_snapshot(line_item_id);

-- cpq_quote_version：按报价头 + 创建时间
CREATE INDEX IF NOT EXISTS idx_qv_header ON cpq_quote_version(header_id, create_time);

-- cpq_quote_template：按类型
CREATE INDEX IF NOT EXISTS idx_qt_type ON cpq_quote_template(template_type);

-- D05 审批域 ================================

-- cpq_approval_rule：按规则类型
CREATE INDEX IF NOT EXISTS idx_arule_type ON cpq_approval_rule(rule_type, status);

-- cpq_approval_chain：按关联ID
CREATE INDEX IF NOT EXISTS idx_achain_ref ON cpq_approval_chain(reference_id, reference_type);

-- cpq_approval_record：按审批人 + 状态
CREATE INDEX IF NOT EXISTS idx_arec_approver ON cpq_approval_record(approver_id, status);
CREATE INDEX IF NOT EXISTS idx_arec_chain ON cpq_approval_record(chain_id);

-- cpq_approval_matrix：按条件
CREATE INDEX IF NOT EXISTS idx_amat_condition ON cpq_approval_matrix(amount_min, amount_max);

-- D06 客户渠道 ==============================

-- cpq_customer_account：按名称
CREATE INDEX IF NOT EXISTS idx_ca_name ON cpq_customer_account(account_name);
CREATE INDEX IF NOT EXISTS idx_ca_code ON cpq_customer_account(account_code);

-- cpq_channel：按类型
CREATE INDEX IF NOT EXISTS idx_ch_type ON cpq_channel(channel_type);

-- cpq_agreement_price：按客户+产品
CREATE INDEX IF NOT EXISTS idx_aprice_customer ON cpq_agreement_price(account_id, product_id);
CREATE INDEX IF NOT EXISTS idx_aprice_eff ON cpq_agreement_price(effective_date, expiry_date);

-- cpq_territory：按代码
CREATE INDEX IF NOT EXISTS idx_terr_code ON cpq_territory(territory_code);

-- D07 系统配置 ==============================

-- cpq_system_config：按配置键
CREATE INDEX IF NOT EXISTS idx_sc_key ON cpq_system_config(config_key);

-- cpq_abac_policy：按类型 + 主体
CREATE INDEX IF NOT EXISTS idx_abac_type ON cpq_abac_policy(policy_type);
CREATE INDEX IF NOT EXISTS idx_abac_subject ON cpq_abac_policy(subject_type, subject_value);

-- D08 集成 / ECN ============================

-- cpq_integration_connector：按类型
CREATE INDEX IF NOT EXISTS idx_icon_type ON cpq_integration_connector(connector_type);

-- cpq_integration_log：按连接器ID + 时间
CREATE INDEX IF NOT EXISTS idx_ilog_connector ON cpq_integration_log(connector_id, sync_time);

-- cpq_ecn_change_order：按状态
CREATE INDEX IF NOT EXISTS idx_eco_status ON cpq_ecn_change_order(status);

-- cpq_ecn_change_item：按变更单
CREATE INDEX IF NOT EXISTS idx_eci_order ON cpq_ecn_change_item(order_id);

-- cpq_ecn_impact_analysis：按变更单
CREATE INDEX IF NOT EXISTS idx_eia_order ON cpq_ecn_impact_analysis(order_id);

-- cpq_ecn_approval：按变更单
CREATE INDEX IF NOT EXISTS idx_ea_order ON cpq_ecn_approval(order_id);

-- 竞品 / 迁移 / 知识库 =====================

-- cpq_competitor：按名称
CREATE INDEX IF NOT EXISTS idx_comp_name ON cpq_competitor(competitor_name);

-- cpq_competitor_product：按竞品ID
CREATE INDEX IF NOT EXISTS idx_cp_competitor ON cpq_competitor_product(competitor_id);

-- cpq_migration_task：按状态
CREATE INDEX IF NOT EXISTS idx_mt_status ON cpq_migration_task(status);

-- cpq_knowledge_article：按类别 + 全文索引
CREATE INDEX IF NOT EXISTS idx_ka_category ON cpq_knowledge_article(category);
-- 全文索引（MySQL 8.0+）
-- ALTER TABLE cpq_knowledge_article ADD FULLTEXT INDEX ft_ka_content (title, content);

-- cpq_plant：按代码
CREATE INDEX IF NOT EXISTS idx_plant_code ON cpq_plant(plant_code);

-- ============================================
-- 索引验证查询
-- SELECT table_name, index_name, group_concat(column_name ORDER BY seq_in_index) as columns
-- FROM information_schema.statistics
-- WHERE table_schema = 'Ruoyi_CPQ' AND table_name LIKE 'cpq_%'
-- GROUP BY table_name, index_name ORDER BY table_name, index_name;
-- ============================================
