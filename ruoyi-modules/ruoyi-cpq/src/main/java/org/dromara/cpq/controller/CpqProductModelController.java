package org.dromara.cpq.controller;

import cn.hutool.core.util.StrUtil;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.cpq.domain.bo.CpqProductModelBo;
import org.dromara.cpq.domain.vo.CpqProductModelVo;
import org.dromara.cpq.service.ICpqProductModelService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

import java.util.List;

/**
 * CPQ 产品模型管理（支持产品目录下的产品 CRUD）
 *
 * @author CPQ Team
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/cpq/product/model")
public class CpqProductModelController extends BaseController {

    private final ICpqProductModelService modelService;
    private final JdbcTemplate jdbcTemplate;

    @GetMapping("/list")
    public TableDataInfo<CpqProductModelVo> list(CpqProductModelBo bo, PageQuery pageQuery) {
        return modelService.selectPageModelList(bo, pageQuery);
    }

    @GetMapping("/{modelId}")
    public R<CpqProductModelVo> getInfo(@PathVariable Long modelId) {
        return R.ok(modelService.selectModelById(modelId));
    }

    @GetMapping("/code/{modelCode}")
    public R<CpqProductModelVo> getByCode(@PathVariable String modelCode) {
        return R.ok(modelService.selectModelByCode(modelCode));
    }

    @GetMapping("/search")
    public R<List<CpqProductModelVo>> search(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String lifecycleStatus,
            @RequestParam(required = false) String configType) {
        return R.ok(modelService.searchModels(keyword, lifecycleStatus, configType));
    }

    @Log(title = "CPQ产品", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody CpqProductModelBo bo) {
        return toAjax(modelService.insertModel(bo));
    }

    @Log(title = "CPQ产品", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody CpqProductModelBo bo) {
        return toAjax(modelService.updateModel(bo));
    }

    @Log(title = "CPQ产品", businessType = BusinessType.DELETE)
    @DeleteMapping("/{modelId}")
    public R<Void> remove(@PathVariable Long modelId) {
        return toAjax(modelService.deleteModel(modelId));
    }

    @Log(title = "CPQ产品", businessType = BusinessType.DELETE)
    @DeleteMapping("/batch")
    public R<Void> removeBatch(@RequestBody Long[] modelIds) {
        return toAjax(modelService.deleteModelByIds(modelIds));
    }

    /**
     * 下载导入模版 CSV
     */
    @GetMapping("/import/template")
    public void downloadTemplate(jakarta.servlet.http.HttpServletResponse response) throws Exception {
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment;filename=CPQ产品导入模版.csv");
        java.io.PrintWriter w = response.getWriter();
        w.write("﻿"); // BOM for Excel UTF-8
        w.println("电芯编码,电芯型号,参考尺寸,标称电压,标称容量,最大持续电流,最大脉冲电流,工作温度,最大尺寸,重量(g),存储温度,应用范围,成品编码,成品描述,机型号,插头线型号,插头方向,线长(mm),是否绕线,是否桶装,运输方式,产品类型,锂亚电芯数,结构,装箱数量,外贴商标,工时,近一年出货量");
        w.println("ER14250,ER14250,1/2AA,3.6V,1200mAh,50mA,100mA,-55~85℃,Φ14.5×25mm,10,-40~60℃,\"GPS,安防\",ER14250-BP-001,ER14250电池包 50mm线长 JST插头,TYPE-A,JST-XH-2P,正向,50,是,是,空运,电池包,1,单体,100,自有商标,2.5,5000");
        w.println("ER14505,ER14505,AA,3.6V,2400mAh,100mA,200mA,-40~+85℃,Φ14.5×50mm,18,-40~60℃,智能水表,ER14505-BP-001,ER14505电池包 200mm Molex,TYPE-B,Molex-51021,反向,200,否,否,海运,电池包,2,双串,50,自有商标,3.0,3000");
        w.println();
        w.println("# 填写说明:");
        w.println("#  带*为必填项; 尺寸格式: 14.5×25mm 或 Φ14.5x25.0mm");
        w.println("#  温度格式: -55~85℃ / -60℃~+85℃ / -40~+125℃");
        w.println("#  多值字段(如应用范围)用逗号分隔，需加英文双引号包裹");
        w.println("#  数值类字段填数字即可，不要带单位");
        w.flush();
    }

    /**
     * 产品分类树（三级，用于导入弹窗级联选择）
     */
    @GetMapping("/category/tree")
    public R<List<Map<String, Object>>> categoryTree() {
        var rows = jdbcTemplate.queryForList(
            "SELECT category_id, parent_category_id, category_level, category_code, category_name " +
            "FROM cpq_product_category WHERE status='0' AND del_flag='0' AND category_level<=3 " +
            "ORDER BY category_level, parent_category_id, category_id");
        // 构建树：level1 → children(level2) → children(level3)
        List<Map<String, Object>> result = new ArrayList<>();
        Map<Long, Map<String, Object>> nodeMap = new HashMap<>();
        for (Map<String, Object> row : rows) {
            Long id = (Long) row.get("category_id");
            Map<String, Object> node = new HashMap<>();
            node.put("id", id);
            node.put("label", row.get("category_name"));
            node.put("level", row.get("category_level"));
            node.put("parentId", row.get("parent_category_id"));
            node.put("children", new ArrayList<>());
            nodeMap.put(id, node);
            if (row.get("category_level").equals(1)) {
                result.add(node);
            } else {
                Long pid = (Long) row.get("parent_category_id");
                var parent = nodeMap.get(pid);
                if (parent != null) {
                    @SuppressWarnings("unchecked")
                    var children = (List<Map<String, Object>>) parent.get("children");
                    children.add(node);
                }
            }
        }
        return R.ok(result);
    }

    /**
     * 产品数据导入
     */
    @Log(title = "导入产品", businessType = BusinessType.INSERT)
    @PostMapping("/import")
    public R<Map<String, Object>> importProducts(
            @RequestParam("file") MultipartFile file,
            @RequestParam("categoryId") Long categoryId,
            @RequestParam(value = "basePrice", defaultValue = "5.00") BigDecimal basePrice,
            @RequestParam(value = "minOrderQty", defaultValue = "1") Integer minOrderQty,
            @RequestParam(value = "leadTimeDays", defaultValue = "7") Integer leadTimeDays) {

        try {
            // 解析文件
            List<Map<String, String>> rows = parseProductFile(file);
            if (rows.isEmpty()) return R.fail("文件中无有效数据");

            // 去重
            Map<String, Map<String, String>> unique = new LinkedHashMap<>();
            for (Map<String, String> row : rows) {
                String code = row.get("成品编码");
                if (code == null || code.isBlank()) continue;
                unique.putIfAbsent(code.trim(), row);
            }

            // 获取ID起始值
            long now = System.currentTimeMillis();
            Long maxModelId = jdbcTemplate.queryForObject(
                "SELECT COALESCE(MAX(model_id),0) FROM cpq_product_model", Long.class);
            Long maxAttrId = jdbcTemplate.queryForObject(
                "SELECT COALESCE(MAX(attribute_id),0) FROM cpq_product_attribute", Long.class);
            Long maxSbomHdrId = jdbcTemplate.queryForObject(
                "SELECT COALESCE(MAX(sbom_header_id),0) FROM cpq_sbom_header", Long.class);
            Long maxSbomLineId = jdbcTemplate.queryForObject(
                "SELECT COALESCE(MAX(sbom_line_id),0) FROM cpq_sbom_line", Long.class);

            long modelId = Math.max(maxModelId + 1, now % 100000);
            long attrId = Math.max(maxAttrId + 1, now % 100000 + 1000);
            long sbomHdrId = Math.max(maxSbomHdrId + 1, now % 100000 + 2000);
            long sbomLineId = Math.max(maxSbomLineId + 1, now % 100000 + 3000);

            int modelCount = 0, attrCount = 0, sbomHdrCount = 0, sbomLineCount = 0, mappingCount = 0;
            Set<String> mappingsAdded = new HashSet<>();
            String nowStr = LocalDateTime.now().toString().substring(0, 19);

            for (Map<String, String> row : unique.values()) {
                String code = row.get("成品编码").trim();
                String name = row.getOrDefault("成品描述", code).trim();
                String desc = StrUtil.join(" / ",
                    row.getOrDefault("产品类型", ""),
                    row.getOrDefault("机型号", ""),
                    row.getOrDefault("结构", ""));
                if (desc.length() > 500) desc = desc.substring(0, 500);

                // ★ UPSERT：重复导入时更新，不报错
                jdbcTemplate.update(
                    "INSERT INTO cpq_product_model (model_id,tenant_id,catalog_id,category_id,model_code,model_name,description,lifecycle_status,config_type,base_price,currency,min_order_qty,lead_time_days,status,del_flag,create_time) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE model_name=VALUES(model_name),description=VALUES(description),base_price=VALUES(base_price),min_order_qty=VALUES(min_order_qty),lead_time_days=VALUES(lead_time_days)",
                    modelId, "000000", 11L, categoryId, code, name, desc, "ACTIVE", "STANDARD",
                    basePrice, "CNY", minOrderQty, leadTimeDays, "0", "0", nowStr);
                // ★ 查出实际 model_id（UPSERT 后可能是旧记录的 ID，不是上面生成的 modelId）
                Long actualModelId = jdbcTemplate.queryForObject(
                    "SELECT model_id FROM cpq_product_model WHERE model_code=? AND tenant_id='000000'", Long.class, code);
                if (actualModelId == null) actualModelId = modelId;
                else modelId = actualModelId; // 同步后续 BOM 使用的 ID
                modelCount++;

                // ★ 先删除旧属性 + 旧BOM（幂等，支持重复导入）
                jdbcTemplate.update("DELETE FROM cpq_sbom_line WHERE sbom_header_id IN (SELECT sbom_header_id FROM cpq_sbom_header WHERE model_id=?)", modelId);
                jdbcTemplate.update("DELETE FROM cpq_sbom_header WHERE model_id=?", modelId);
                jdbcTemplate.update("DELETE FROM cpq_product_attribute WHERE model_id=?", modelId);
                // 批量收集属性
                java.util.List<Object[]> attrBatch = new java.util.ArrayList<>();
                String[][] cellAttrs = {{"电芯编码","STRING"},{"电芯型号","STRING"},{"参考尺寸","STRING"},{"标称电压","NUMBER"},{"标称容量","STRING"},{"最大持续电流","STRING"},{"最大脉冲电流","STRING"},{"工作温度","STRING"},{"最大尺寸","STRING"},{"重量(g)","STRING"},{"存储温度","STRING"},{"应用范围","STRING"}};
                for (int i = 0; i < cellAttrs.length; i++) {
                    String an = cellAttrs[i][0], at = cellAttrs[i][1], v = row.getOrDefault(an, "").trim();
                    if (!v.isEmpty()) attrBatch.add(new Object[]{attrId++, "000000", modelId, "电芯规格", an, v, "1", "1", i, at, i, "0", nowStr});
                }
                String sizeRef = row.getOrDefault("最大尺寸", row.getOrDefault("参考尺寸", ""));
                java.util.regex.Matcher sm = java.util.regex.Pattern.compile("(\\d+\\.?\\d*)\\s*[×xX]\\s*(\\d+\\.?\\d*)").matcher(sizeRef);
                if (sm.find()) {
                    String w = sm.group(1), h = sm.group(2);
                    attrBatch.add(new Object[]{attrId++, "000000", modelId, "物理规格", "外形宽度", w, "1", "1", 0, "NUMBER", 0, "0", nowStr});
                    attrBatch.add(new Object[]{attrId++, "000000", modelId, "物理规格", "外形高度", h, "1", "1", 1, "NUMBER", 1, "0", nowStr});
                    attrBatch.add(new Object[]{attrId++, "000000", modelId, "物理规格", "外形长度", w, "1", "1", 2, "NUMBER", 2, "0", nowStr});
                }
                String ts = row.getOrDefault("工作温度", "").replace("℃", "");
                java.util.regex.Matcher tm = java.util.regex.Pattern.compile("([-+]?\\d+)\\s*[~～-]\\s*([-+]?\\d+)").matcher(ts);
                if (tm.find()) {
                    attrBatch.add(new Object[]{attrId++, "000000", modelId, "电气性能", "工作温度下限", tm.group(1), "1", "1", 0, "NUMBER", 0, "0", nowStr});
                    attrBatch.add(new Object[]{attrId++, "000000", modelId, "电气性能", "工作温度上限", tm.group(2), "1", "1", 1, "NUMBER", 1, "0", nowStr});
                }
                String[][] prodAttrs = {{"机型号","STRING"},{"插头线型号","STRING"},{"插头方向","STRING"},{"线长(mm)","NUMBER"},{"是否绕线","BOOLEAN"},{"是否桶装","BOOLEAN"},{"运输方式","STRING"},{"产品类型","STRING"},{"锂亚电芯数","NUMBER"},{"结构","STRING"},{"装箱数量","NUMBER"},{"外贴商标","STRING"},{"工时","NUMBER"},{"近一年出货量","NUMBER"}};
                for (int i = 0; i < prodAttrs.length; i++) {
                    String an = prodAttrs[i][0], at = prodAttrs[i][1], v = row.getOrDefault(an, "").trim();
                    attrBatch.add(new Object[]{attrId++, "000000", modelId, "成品规格", an, v, "1", an.equals("商标")||an.equals("工时")?"0":"1", i, at, i, "0", nowStr});
                }
                String[][] defs = {{"防护信息","IP等级","IP68","STRING"},{"电气性能","使用寿命(年)","10","NUMBER"},{"认证信息","认证列表","CE,RoHS,UL1642,UN38.3","STRING"}};
                for (String[] da : defs) attrBatch.add(new Object[]{attrId++, "000000", modelId, da[0], da[1], da[2], "1", "1", 0, da[3], 0, "0", nowStr});

                jdbcTemplate.batchUpdate("INSERT INTO cpq_product_attribute (attribute_id,tenant_id,model_id,attr_category,attr_name,attr_value,is_configurable,is_required,display_order,data_type,sort_order,del_flag,create_time) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", attrBatch);
                attrCount += attrBatch.size();

                // 维度映射 TEMP
                for (String[] dm : new String[][]{{"TEMP_MATCH","电气性能","工作温度下限","PRODUCT_COMPARE"},{"TEMP_MATCH","电气性能","工作温度上限","PRODUCT_COMPARE"}}) {
                    if (mappingsAdded.add(dm[0]+"|"+dm[1]+"|"+dm[2])) {
                        jdbcTemplate.update("INSERT INTO cpq_dimension_attr_mapping (mapping_id,tenant_id,dimension_code,product_attr_category,product_attr_name,mapping_role,sort_order,status,del_flag) VALUES (?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE mapping_role=VALUES(mapping_role)",
                            Long.parseLong("1"+String.format("%04d",mappingsAdded.size())), "000000", dm[0], dm[1], dm[2], dm[3], 0, "0", "0");
                        mappingCount++;
                    }
                }

                // BOM
                jdbcTemplate.update("INSERT INTO cpq_sbom_header (sbom_header_id,tenant_id,model_id,sbom_name,sbom_version,status,del_flag,create_time) VALUES (?,?,?,?,?,?,?,?)",
                    sbomHdrId, "000000", modelId, "BOM-" + code, "1.0", "0", "0", nowStr);
                sbomHdrCount++;

                String cellCode = row.getOrDefault("电芯编码", "").trim();
                String cellModel = row.getOrDefault("电芯型号", cellCode).trim();
                int cellCount = 1;
                try { cellCount = Integer.parseInt(row.getOrDefault("锂亚电芯数", "1").trim()); } catch (Exception ignored) {}
                jdbcTemplate.update("INSERT INTO cpq_sbom_line (sbom_line_id,tenant_id,sbom_header_id,parent_line_id,line_number,item_code,item_name,item_type,quantity,unit,is_required,is_replaceable,sort_order,del_flag,create_time) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                    sbomLineId++, "000000", sbomHdrId, null, 10, cellCode, "锂亚电芯 - " + cellModel, "HOST", cellCount, "PCS", "1", "0", 10, "0", nowStr);
                sbomLineCount++;

                String plugModel = row.getOrDefault("插头线型号", "").trim();
                if (!plugModel.isEmpty()) {
                    jdbcTemplate.update("INSERT INTO cpq_sbom_line (sbom_line_id,tenant_id,sbom_header_id,parent_line_id,line_number,item_code,item_name,item_type,quantity,unit,is_required,is_replaceable,sort_order,del_flag,create_time) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                        sbomLineId++, "000000", sbomHdrId, null, 20, plugModel, "插头线 - " + plugModel, "ACCESSORY", 1, "PCS", "1", "0", 20, "0", nowStr);
                    sbomLineCount++;
                }

                // 维度映射 (9条，去重)
                String[][] dimMaps = {
                    {"SIZE_MATCH","物理规格","外形长度","BOTH"},{"SIZE_MATCH","物理规格","外形宽度","BOTH"},{"SIZE_MATCH","物理规格","外形高度","BOTH"},
                    {"USAGE_MATCH","电芯规格","应用范围","PRODUCT_COMPARE"},{"TEMP_MATCH","电芯规格","工作温度","PRODUCT_COMPARE"},
                    {"LIFE_MATCH","电气性能","使用寿命(年)","PRODUCT_COMPARE"},{"SEAL_MATCH","防护信息","IP等级","BOTH"},
                    {"CERT_MATCH","认证信息","认证列表","PRODUCT_COMPARE"},{"BONUS","成品规格","近一年出货量","PRODUCT_COMPARE"}
                };
                for (String[] dm : dimMaps) {
                    String key = dm[0] + "|" + dm[1] + "|" + dm[2];
                    if (mappingsAdded.add(key)) {
                        jdbcTemplate.update("INSERT INTO cpq_dimension_attr_mapping (mapping_id,tenant_id,dimension_code,product_attr_category,product_attr_name,mapping_role,sort_order,status,del_flag) VALUES (?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE mapping_role=VALUES(mapping_role)",
                            Long.parseLong("1" + String.format("%04d", mappingsAdded.size())), "000000", dm[0], dm[1], dm[2], dm[3], 0, "0", "0");
                        mappingCount++;
                    }
                }

                sbomHdrId++;
                modelId++;
            }

            Map<String, Object> result = new HashMap<>();
            result.put("products", unique.size());
            result.put("models", modelCount);
            result.put("attributes", attrCount);
            result.put("sbomHeaders", sbomHdrCount);
            result.put("sbomLines", sbomLineCount);
            result.put("mappings", mappingCount);
            result.put("skipped", rows.size() - unique.size());
            return R.ok(result);
        } catch (Exception e) {
            return R.fail("导入失败: " + e.getMessage());
        }
    }

    private List<Map<String, String>> parseProductFile(MultipartFile file) throws Exception {
        String filename = file.getOriginalFilename();
        if (filename == null) return Collections.emptyList();
        String ext = filename.toLowerCase();
        List<Map<String, String>> rows = new ArrayList<>();

        if (ext.endsWith(".xlsx") || ext.endsWith(".xls")) {
            java.io.InputStream is = file.getInputStream();
            org.apache.poi.ss.usermodel.Workbook wb = org.apache.poi.ss.usermodel.WorkbookFactory.create(is);
            org.apache.poi.ss.usermodel.Sheet sheet = wb.getSheetAt(0);
            org.apache.poi.ss.usermodel.Row headerRow = sheet.getRow(0);
            List<String> headers = new ArrayList<>();
            for (int i = 0; i < headerRow.getLastCellNum(); i++) {
                var cell = headerRow.getCell(i);
                headers.add(cell != null ? cell.getStringCellValue().trim() : "");
            }

            for (int r = 1; r <= sheet.getLastRowNum(); r++) {
                org.apache.poi.ss.usermodel.Row row = sheet.getRow(r);
                if (row == null) continue;
                Map<String, String> map = new LinkedHashMap<>();
                for (int i = 0; i < headers.size(); i++) {
                    String h = headers.get(i);
                    if (h.isEmpty()) continue;
                    String v = "";
                    try {
                        var cell = row.getCell(i);
                        if (cell != null) {
                            switch (cell.getCellType()) {
                                case STRING: v = cell.getStringCellValue().trim(); break;
                                case NUMERIC: v = String.valueOf((long)cell.getNumericCellValue()); break;
                                case BOOLEAN: v = String.valueOf(cell.getBooleanCellValue()); break;
                                default: v = "";
                            }
                        }
                    } catch (Exception ignored) {}
                    map.put(h, v);
                }
                if (!map.isEmpty()) rows.add(map);
            }
            wb.close();
        } else {
            // CSV/TSV — 自动检测编码（UTF-8 BOM → UTF-8 → GBK）
            java.io.InputStream is = file.getInputStream();
            byte[] bytes = is.readAllBytes();
            is.close();

            // 去掉 UTF-8 BOM（如果存在）
            String content;
            if (bytes.length >= 3 && bytes[0] == (byte)0xEF && bytes[1] == (byte)0xBB && bytes[2] == (byte)0xBF) {
                content = new String(bytes, 3, bytes.length - 3, java.nio.charset.StandardCharsets.UTF_8);
            } else {
                // 先尝试 UTF-8，如果包含无效字节则回退到 GBK
                try {
                    content = new String(bytes, java.nio.charset.StandardCharsets.UTF_8);
                    // 检查是否有乱码特征（高位字节的非 UTF-8 序列会变成 �）
                    if (content.contains("�")) {
                        content = new String(bytes, java.nio.charset.Charset.forName("GBK"));
                    }
                } catch (Exception e) {
                    content = new String(bytes, java.nio.charset.Charset.forName("GBK"));
                }
            }

            java.io.BufferedReader br = new java.io.BufferedReader(new java.io.StringReader(content));
            char delimiter = ext.endsWith(".tsv") ? '\t' : ',';
            // ★ 检测分隔符：如果第一行没有逗号但有其他分隔符，自动识别
            String firstLineForDetect = br.readLine();
            br.close();
            if (firstLineForDetect != null && !firstLineForDetect.contains(",") && firstLineForDetect.contains("\t")) {
                delimiter = '\t';
            }

            java.io.BufferedReader br2 = new java.io.BufferedReader(new java.io.StringReader(content));
            com.opencsv.CSVReader reader = new com.opencsv.CSVReaderBuilder(br2).withCSVParser(
                new com.opencsv.CSVParserBuilder().withSeparator(delimiter).build()).build();
            String[] headers = reader.readNext();
            if (headers == null) { reader.close(); return rows; }

            String[] line;
            while ((line = reader.readNext()) != null) {
                Map<String, String> map = new LinkedHashMap<>();
                for (int i = 0; i < headers.length && i < line.length; i++)
                    map.put(headers[i].trim(), line[i].trim());
                if (!map.isEmpty()) rows.add(map);
            }
            reader.close();
        }
        return rows;
    }
}
