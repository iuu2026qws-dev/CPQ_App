#!/usr/bin/env python3
"""
POC ER微型电池 数据处理脚本
==============================
输入：客户POC数据（Excel/CSV），包含电芯+成品28个字段
输出：按CPQ数据库表结构拆分的CSV + 导入SQL，可直接导入数据库

输出文件（output/ 目录）：
  cpq_product_model.csv             — 产品型号表（成品）
  cpq_product_attribute.csv         — 产品属性表（EAV模型）
  cpq_sbom_header.csv               — SBOM头表（成品BOM）
  cpq_sbom_line.csv                 — SBOM行表（成品→电芯关联）
  cpq_dimension_attr_mapping.csv    — 维度属性映射（新增）
  insert_all.sql                    — INSERT 语句导入脚本（可直接执行）

配置：
  model_id 起始: 6001
  category_id: 507 (锂亚硫酰氯电池)
  catalog_id:  11  (EVE 标准产品目录)
"""

import csv
import os
import sys
from collections import OrderedDict
from datetime import datetime

# ============================================================
# 配置参数
# ============================================================
TENANT_ID = '000000'
CATEGORY_ID = 507       # 锂亚硫酰氯电池
CATALOG_ID = 11         # EVE 标准产品目录（国内）

# ID起始值
MODEL_ID_START = 6001
ATTRIBUTE_ID_START = 20001
SBOM_HEADER_ID_START = 2074100100
SBOM_LINE_ID_START = 2074100200
DIM_MAPPING_ID_START = 100

OUTPUT_DIR = 'output'

# ============================================================
# 字段映射
# ============================================================

# 电芯规格（12个字段）→ attr_category='电芯规格'
CELL_ATTRS = OrderedDict([
    ('电芯编码',     'STRING'),
    ('电芯型号',     'STRING'),
    ('参考尺寸',     'STRING'),
    ('标称电压',     'NUMBER'),
    ('标称容量',     'STRING'),
    ('最大持续电流', 'STRING'),
    ('最大脉冲电流', 'STRING'),
    ('工作温度',     'STRING'),
    ('最大尺寸',     'STRING'),
    ('重量',         'STRING'),
    ('存储温度',     'STRING'),
    ('应用范围',     'STRING'),
])

# 成品规格（14个字段）→ attr_category='成品规格'
PRODUCT_ATTRS = OrderedDict([
    ('机型号',       'STRING'),
    ('插头线型号',   'STRING'),
    ('插头方向',     'STRING'),
    ('线长',         'NUMBER'),
    ('是否绕线',     'BOOLEAN'),
    ('是否桶装',     'BOOLEAN'),
    ('运输方式',     'STRING'),
    ('产品类型',     'STRING'),
    ('锂亚电芯数',   'NUMBER'),
    ('结构',         'STRING'),
    ('装箱数量',     'NUMBER'),
    ('外贴商标',     'STRING'),
    ('工时',         'NUMBER'),
    ('近一年出货量', 'NUMBER'),
])

# 防护信息（1个字段）→ attr_category='防护信息'，默认值 IP68
PROTECTION_ATTRS = OrderedDict([
    ('IP等级', 'STRING'),
])

# 28个输入表头（顺序）
ALL_HEADERS = (
    ['电芯编码', '电芯型号', '参考尺寸', '标称电压', '标称容量', '最大持续电流',
     '最大脉冲电流', '工作温度', '最大尺寸', '重量', '存储温度', '应用范围']
    + ['成品编码', '成品描述', '机型号', '插头线型号', '插头方向', '线长',
       '是否绕线', '是否桶装', '运输方式', '产品类型', '锂亚电芯数', '结构',
       '装箱数量', '外贴商标', '工时', '近一年出货量']
)


def read_input(filepath):
    """读取输入文件，支持 CSV / Excel (.xlsx, .xls)"""
    if not os.path.exists(filepath):
        print(f"❌ 文件不存在: {filepath}")
        sys.exit(1)

    ext = os.path.splitext(filepath)[1].lower()

    if ext in ('.xlsx', '.xls'):
        try:
            import openpyxl
        except ImportError:
            print("❌ 读取 Excel 需要 openpyxl: pip3 install openpyxl")
            sys.exit(1)
        wb = openpyxl.load_workbook(filepath, data_only=True)
        ws = wb.active
        rows = []
        for row in ws.iter_rows(min_row=2, values_only=True):
            d = {}
            for i, header in enumerate(ALL_HEADERS):
                val = row[i] if row[i] is not None else ''
                d[header] = str(val).strip()
            rows.append(d)
        return rows
    else:
        with open(filepath, 'r', encoding='utf-8-sig') as f:
            delimiter = '\t' if ext == '.tsv' else ','
            reader = csv.DictReader(f, delimiter=delimiter)
            rows = []
            for row in reader:
                clean = {}
                for k, v in row.items():
                    k2 = k.strip() if k else ''
                    clean[k2] = v.strip() if v else ''
                rows.append(clean)
            return rows


def process_data(rows):
    """拆分数据：按成品编码去重，提取关联的电芯信息"""
    products = OrderedDict()

    for i, row in enumerate(rows, start=2):
        product_code = row.get('成品编码', '').strip()
        if not product_code:
            print(f"⚠️  第{i}行：成品编码为空，跳过")
            continue

        if product_code in products:
            print(f"⚠️  成品编码 {product_code} 重复（第{i}行），保留第一条")
            continue

        pd_data = {
            'product_code': product_code,
            'product_description': row.get('成品描述', '').strip(),
        }

        # 成品规格
        for attr_name in PRODUCT_ATTRS:
            pd_data[attr_name] = row.get(attr_name, '').strip()

        # 电芯规格
        for attr_name in CELL_ATTRS:
            pd_data[attr_name] = row.get(attr_name, '').strip()

        # IP等级固定值
        pd_data['IP等级'] = 'IP68'

        # 关联用
        pd_data['_cell_code'] = row.get('电芯编码', '').strip()
        pd_data['_cell_model'] = row.get('电芯型号', '').strip()

        products[product_code] = pd_data

    return products


def generate_outputs(products):
    """生成所有输出CSV文件"""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    model_id = MODEL_ID_START
    attr_id = ATTRIBUTE_ID_START
    sbom_hdr_id = SBOM_HEADER_ID_START
    sbom_line_id = SBOM_LINE_ID_START
    dim_mapping_id = DIM_MAPPING_ID_START

    code_to_model_id = {}

    model_rows = []
    attr_rows = []
    sbom_header_rows = []
    sbom_line_rows = []
    dim_mapping_rows = []

    # 维度映射记录去重（全局唯一）
    dim_mappings_added = set()

    for product_code, pd in products.items():
        m_id = model_id
        code_to_model_id[product_code] = m_id
        model_id += 1

        # --- cpq_product_model ---
        desc_parts = [
            pd.get('产品类型', ''),
            pd.get('机型号', ''),
            pd.get('结构', ''),
        ]
        description = ' / '.join(p for p in desc_parts if p).strip()

        model_rows.append({
            'model_id': m_id,
            'tenant_id': TENANT_ID,
            'catalog_id': CATALOG_ID,
            'category_id': CATEGORY_ID,
            'model_code': product_code,
            'model_name': pd.get('product_description', product_code),
            'description': description,
            'lifecycle_status': 'ACTIVE',
            'config_type': 'STANDARD',
            'base_price': '\\N',
            'currency': 'CNY',
            'min_order_qty': 1,
            'lead_time_days': '\\N',
            'status': '0',
            'del_flag': '0',
            'create_time': now,
        })

        # --- cpq_product_attribute（电芯规格）---
        order = 0
        for attr_name in CELL_ATTRS:
            value = pd.get(attr_name, '')
            if value:
                dtype = CELL_ATTRS[attr_name]
                attr_rows.append({
                    'attribute_id': attr_id,
                    'tenant_id': TENANT_ID,
                    'model_id': m_id,
                    'attr_category': '电芯规格',
                    'attr_name': attr_name,
                    'attr_value': value,
                    'is_configurable': '1',
                    'is_required': '1',
                    'display_order': order,
                    'data_type': dtype,
                    'sort_order': order,
                    'del_flag': '0',
                    'create_time': now,
                })
                attr_id += 1
                order += 1

        # --- cpq_product_attribute（成品规格）---
        order = 0
        for attr_name in PRODUCT_ATTRS:
            value = pd.get(attr_name, '')
            if value:
                dtype = PRODUCT_ATTRS[attr_name]
                required = '1'
                if attr_name in ('外贴商标', '工时'):
                    required = '0'
                attr_rows.append({
                    'attribute_id': attr_id,
                    'tenant_id': TENANT_ID,
                    'model_id': m_id,
                    'attr_category': '成品规格',
                    'attr_name': attr_name,
                    'attr_value': value,
                    'is_configurable': '1',
                    'is_required': required,
                    'display_order': order,
                    'data_type': dtype,
                    'sort_order': order,
                    'del_flag': '0',
                    'create_time': now,
                })
                attr_id += 1
                order += 1

        # --- cpq_product_attribute（防护信息）---
        for attr_name in PROTECTION_ATTRS:
            value = pd.get(attr_name, '')
            if value:
                attr_rows.append({
                    'attribute_id': attr_id,
                    'tenant_id': TENANT_ID,
                    'model_id': m_id,
                    'attr_category': '防护信息',
                    'attr_name': attr_name,
                    'attr_value': value,
                    'is_configurable': '1',
                    'is_required': '1',
                    'display_order': 0,
                    'data_type': PROTECTION_ATTRS[attr_name],
                    'sort_order': 0,
                    'del_flag': '0',
                    'create_time': now,
                })
                attr_id += 1

        # --- cpq_sbom_header ---
        hdr_id = sbom_hdr_id
        sbom_header_rows.append({
            'sbom_header_id': hdr_id,
            'tenant_id': TENANT_ID,
            'model_id': m_id,
            'sbom_name': f"BOM-{product_code}",
            'sbom_version': '1.0',
            'status': '0',
            'del_flag': '0',
            'create_time': now,
        })
        sbom_hdr_id += 1

        # --- cpq_sbom_line（电芯行）---
        cell_code = pd.get('_cell_code', '')
        cell_model = pd.get('_cell_model', cell_code)
        cell_count_str = pd.get('锂亚电芯数', '1')
        try:
            cell_count = int(float(cell_count_str)) if cell_count_str else 1
        except ValueError:
            cell_count = 1

        line_no = 10
        sbom_line_rows.append({
            'sbom_line_id': sbom_line_id,
            'tenant_id': TENANT_ID,
            'sbom_header_id': hdr_id,
            'parent_line_id': '\\N',
            'line_number': line_no,
            'item_code': cell_code,
            'item_name': f"锂亚电芯 - {cell_model}",
            'item_type': 'HOST',
            'quantity': cell_count,
            'unit': 'PCS',
            'is_required': '1',
            'is_replaceable': '0',
            'sort_order': line_no,
            'del_flag': '0',
            'create_time': now,
        })
        sbom_line_id += 1
        line_no += 10

        # --- cpq_sbom_line（插头线行）---
        plug_model = pd.get('插头线型号', '')
        if plug_model:
            sbom_line_rows.append({
                'sbom_line_id': sbom_line_id,
                'tenant_id': TENANT_ID,
                'sbom_header_id': hdr_id,
                'parent_line_id': '\\N',
                'line_number': line_no,
                'item_code': plug_model,
                'item_name': f"插头线 - {plug_model}",
                'item_type': 'ACCESSORY',
                'quantity': 1,
                'unit': 'PCS',
                'is_required': '1',
                'is_replaceable': '0',
                'sort_order': line_no,
                'del_flag': '0',
                'create_time': now,
            })
            sbom_line_id += 1

        # --- cpq_dimension_attr_mapping（维度映射）---
        # 每条映射去重
        dim_mappings = [
            ('SIZE_MATCH',    '电芯规格', '参考尺寸',    'BOTH'),
            ('SIZE_MATCH',    '电芯规格', '最大尺寸',    'BOTH'),
            ('USAGE_MATCH',   '电芯规格', '应用范围',    'PRODUCT_COMPARE'),
            ('TEMP_MATCH',    '电芯规格', '工作温度',    'PRODUCT_COMPARE'),
            ('LIFE_MATCH',    '电芯规格', '标称容量',    'PRODUCT_COMPARE'),
            ('SEAL_MATCH',    '防护信息', 'IP等级',      'BOTH'),
            ('BONUS',         '成品规格', '近一年出货量', 'PRODUCT_COMPARE'),
        ]
        for dcode, dcat, dname, drole in dim_mappings:
            key = (dcode, dcat, dname)
            if key not in dim_mappings_added:
                dim_mappings_added.add(key)
                dim_mapping_rows.append({
                    'mapping_id': dim_mapping_id,
                    'tenant_id': TENANT_ID,
                    'dimension_code': dcode,
                    'product_attr_category': dcat,
                    'product_attr_name': dname,
                    'mapping_role': drole,
                    'sort_order': 0,
                    'status': '0',
                    'del_flag': '0',
                })
                dim_mapping_id += 1

    # ============================================================
    # 写 CSV 文件
    # ============================================================

    write_csv(f'{OUTPUT_DIR}/cpq_product_model.csv', [
        'model_id', 'tenant_id', 'catalog_id', 'category_id', 'model_code',
        'model_name', 'description', 'lifecycle_status', 'config_type',
        'base_price', 'currency', 'min_order_qty', 'lead_time_days',
        'status', 'del_flag', 'create_time',
    ], model_rows)

    write_csv(f'{OUTPUT_DIR}/cpq_product_attribute.csv', [
        'attribute_id', 'tenant_id', 'model_id', 'attr_category', 'attr_name',
        'attr_value', 'is_configurable', 'is_required', 'display_order',
        'data_type', 'sort_order', 'del_flag', 'create_time',
    ], attr_rows)

    write_csv(f'{OUTPUT_DIR}/cpq_sbom_header.csv', [
        'sbom_header_id', 'tenant_id', 'model_id', 'sbom_name',
        'sbom_version', 'status', 'del_flag', 'create_time',
    ], sbom_header_rows)

    write_csv(f'{OUTPUT_DIR}/cpq_sbom_line.csv', [
        'sbom_line_id', 'tenant_id', 'sbom_header_id', 'parent_line_id',
        'line_number', 'item_code', 'item_name', 'item_type', 'quantity',
        'unit', 'is_required', 'is_replaceable', 'sort_order', 'del_flag',
        'create_time',
    ], sbom_line_rows)

    write_csv(f'{OUTPUT_DIR}/cpq_dimension_attr_mapping.csv', [
        'mapping_id', 'tenant_id', 'dimension_code', 'product_attr_category',
        'product_attr_name', 'mapping_role', 'sort_order', 'status', 'del_flag',
    ], dim_mapping_rows)

    # ============================================================
    # 生成 INSERT SQL（与 CSV 并列输出）
    # ============================================================
    generate_insert_sql(model_rows, attr_rows, sbom_header_rows, sbom_line_rows, dim_mapping_rows)

    return {
        'products': len(products),
        'model_rows': len(model_rows),
        'attr_rows': len(attr_rows),
        'sbom_headers': len(sbom_header_rows),
        'sbom_lines': len(sbom_line_rows),
        'dim_mappings': len(dim_mapping_rows),
    }


def write_csv(filepath, fieldnames, rows):
    """写CSV，NULL 用 \\N 表示"""
    with open(filepath, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, escapechar='\\')
        writer.writeheader()
        writer.writerows(rows)
    print(f"  ✓ {filepath} ({len(rows)} 行)")


def _sql_value(v):
    """将值转为 SQL 字面量：字符串加引号转义，数字原样，None→NULL"""
    if v is None:
        return 'NULL'
    s = str(v).strip()
    if s == '' or s == '\\N':
        return 'NULL'
    # 尝试判断是否为纯数字（避免给数字加引号）
    try:
        float(s)
        return s
    except ValueError:
        pass
    escaped = s.replace('\\', '\\\\').replace("'", "\\'")
    return "'%s'" % escaped


def _write_inserts(out, table, cols, rows):
    """将行数据写入 INSERT 语句，每批最多 50 行"""
    for i in range(0, len(rows), 50):
        chunk = rows[i:i + 50]
        vals_list = []
        for row in chunk:
            vals = [_sql_value(row.get(c)) for c in cols]
            vals_list.append('(' + ','.join(vals) + ')')
        out.write('INSERT INTO %s (%s) VALUES\n  %s;\n\n' %
                  (table, ','.join(cols), ',\n  '.join(vals_list)))


def generate_insert_sql(model_rows, attr_rows, sbom_header_rows, sbom_line_rows, dim_mapping_rows):
    """生成可直接执行的 INSERT SQL 脚本"""
    path = f'{OUTPUT_DIR}/insert_all.sql'
    now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    with open(path, 'w', encoding='utf-8') as f:
        f.write("""-- ============================================================
-- POC ER微型电池 数据导入 SQL（INSERT 语句）
-- 生成: %s
-- 分类: category_id=507 (锂亚硫酰氯电池) / catalog_id=11
-- 用法: mysql -h HOST -P PORT -u USER -p Ruoyi_CPQ < insert_all.sql
-- ============================================================

SET NAMES utf8mb4;

""" % now)

        # 按依赖顺序：先 model，再 attribute/sbom，最后维护映射
        f.write('-- 1. 产品型号\n')
        _write_inserts(f, 'cpq_product_model', [
            'model_id', 'tenant_id', 'catalog_id', 'category_id', 'model_code',
            'model_name', 'description', 'lifecycle_status', 'config_type',
            'base_price', 'currency', 'min_order_qty', 'lead_time_days',
            'status', 'del_flag', 'create_time',
        ], model_rows)

        f.write('-- 2. 产品属性\n')
        _write_inserts(f, 'cpq_product_attribute', [
            'attribute_id', 'tenant_id', 'model_id', 'attr_category', 'attr_name',
            'attr_value', 'is_configurable', 'is_required', 'display_order',
            'data_type', 'sort_order', 'del_flag', 'create_time',
        ], attr_rows)

        f.write('-- 3. SBOM 头\n')
        _write_inserts(f, 'cpq_sbom_header', [
            'sbom_header_id', 'tenant_id', 'model_id', 'sbom_name',
            'sbom_version', 'status', 'del_flag', 'create_time',
        ], sbom_header_rows)

        f.write('-- 4. SBOM 行\n')
        _write_inserts(f, 'cpq_sbom_line', [
            'sbom_line_id', 'tenant_id', 'sbom_header_id', 'parent_line_id',
            'line_number', 'item_code', 'item_name', 'item_type', 'quantity',
            'unit', 'is_required', 'is_replaceable', 'sort_order', 'del_flag',
            'create_time',
        ], sbom_line_rows)

        # 维度映射：先删再插，避免主键冲突
        f.write('-- 5. 维度映射（先删后插，避免主键冲突）\n')
        mapping_ids = [str(r['mapping_id']) for r in dim_mapping_rows]
        f.write('DELETE FROM cpq_dimension_attr_mapping WHERE mapping_id IN (%s);\n\n' % ','.join(mapping_ids))
        _write_inserts(f, 'cpq_dimension_attr_mapping', [
            'mapping_id', 'tenant_id', 'dimension_code', 'product_attr_category',
            'product_attr_name', 'mapping_role', 'sort_order', 'status', 'del_flag',
        ], dim_mapping_rows)

        # 验证查询
        f.write("""-- ============================================================
-- 验证查询
-- ============================================================
SELECT '成品型号' AS 检查项, COUNT(*) AS 数量 FROM cpq_product_model WHERE model_id >= 6001 AND del_flag = '0'
UNION ALL SELECT '电芯属性', COUNT(*) FROM cpq_product_attribute WHERE attr_category = '电芯规格' AND model_id >= 6001 AND del_flag = '0'
UNION ALL SELECT '成品属性', COUNT(*) FROM cpq_product_attribute WHERE attr_category = '成品规格' AND model_id >= 6001 AND del_flag = '0'
UNION ALL SELECT '防护属性', COUNT(*) FROM cpq_product_attribute WHERE attr_category = '防护信息' AND model_id >= 6001 AND del_flag = '0'
UNION ALL SELECT 'SBOM头', COUNT(*) FROM cpq_sbom_header WHERE model_id >= 6001 AND del_flag = '0'
UNION ALL SELECT 'SBOM行', COUNT(*) FROM cpq_sbom_line sl JOIN cpq_sbom_header sh ON sl.sbom_header_id = sh.sbom_header_id WHERE sh.model_id >= 6001 AND sl.del_flag = '0'
UNION ALL SELECT '维度映射', COUNT(*) FROM cpq_dimension_attr_mapping WHERE mapping_id >= 100 AND del_flag = '0';

-- 成品→电芯 BOM 关联
SELECT pm.model_code AS 成品编码, pm.model_name AS 成品描述,
       sl_h.item_code AS 电芯, sl_h.quantity AS 电芯数量,
       sl_a.item_code AS 插头线
FROM cpq_product_model pm
JOIN cpq_sbom_header sh ON sh.model_id = pm.model_id AND sh.del_flag = '0'
LEFT JOIN cpq_sbom_line sl_h ON sl_h.sbom_header_id = sh.sbom_header_id AND sl_h.item_type = 'HOST' AND sl_h.del_flag = '0'
LEFT JOIN cpq_sbom_line sl_a ON sl_a.sbom_header_id = sh.sbom_header_id AND sl_a.item_type = 'ACCESSORY' AND sl_a.del_flag = '0'
WHERE pm.model_id >= 6001 AND pm.del_flag = '0'
ORDER BY pm.model_code;
""")

    print(f"  ✓ {path}")


def print_summary(stats, products):
    """打印汇总"""
    print("\n" + "=" * 60)
    print("  ✅ 处理完成")
    print("=" * 60)
    print(f"  成品型号(去重):  {stats['products']}")
    print(f"  ─────────────────────────────")
    print(f"  cpq_product_model:           {stats['model_rows']} 行")
    print(f"  cpq_product_attribute:       {stats['attr_rows']} 行")
    print(f"  cpq_sbom_header:             {stats['sbom_headers']} 行")
    print(f"  cpq_sbom_line:               {stats['sbom_lines']} 行")
    print(f"  cpq_dimension_attr_mapping:  {stats['dim_mappings']} 行（新增）")
    print(f"\n  📁 输出: {os.path.abspath(OUTPUT_DIR)}/")
    print(f"  📄 CSV:  {os.path.abspath(OUTPUT_DIR)}/*.csv")
    print(f"  📄 SQL:  {os.path.abspath(OUTPUT_DIR)}/insert_all.sql")
    print(f"\n  ID 范围:")
    print(f"     model_id:      {MODEL_ID_START} ~ {MODEL_ID_START + stats['products'] - 1}")
    print(f"     attribute_id:  {ATTRIBUTE_ID_START} ~ {ATTRIBUTE_ID_START + stats['attr_rows'] - 1}")
    print(f"     sbom_header:   {SBOM_HEADER_ID_START} ~ {SBOM_HEADER_ID_START + stats['sbom_headers'] - 1}")
    print(f"     sbom_line:     {SBOM_LINE_ID_START} ~ {SBOM_LINE_ID_START + stats['sbom_lines'] - 1}")
    print(f"\n  \U0001F4A1 评分权重使用 category_id=507 现有配置，未修改。")
    print(f"  \U0001F4A1 维度映射新增 {stats['dim_mappings']} 行，指向 attr_category=电芯规格/成品规格/防护信息。")
    print()


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    input_file = sys.argv[1]
    print(f"\U0001F4C2 读取: {input_file}")
    rows = read_input(input_file)
    print(f"    读取 {len(rows)} 行")

    print("\U0001F504 拆分成品数据...")
    products = process_data(rows)
    print(f"    成品(去重): {len(products)} 个")

    print("\n\U0001F4DD 生成输出文件...")
    stats = generate_outputs(products)
    print_summary(stats, products)


if __name__ == '__main__':
    main()
