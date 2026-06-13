#!/usr/bin/env python3
"""Sprint 4 batch code generator — Config (D03) + Bundle (D01) CRUD"""
import os

BASE = "/Users/yongfengyang/Library/Mobile Documents/com~apple~CloudDocs/创新万维/0003_纷享销客/0005_Dev_Resource/Project_0005_Ruoyi_CPQ"
MODULE_PATH = os.path.join(BASE, "ruoyi-modules/ruoyi-cpq-config")
SRC = os.path.join(MODULE_PATH, "src/main/java/org/dromara/cpq/config")
PKG = "org.dromara.cpq.config"
CPQ_PKG = "org.dromara.cpq"

# ===== Table definitions =====
# (table_name, class_prefix, pk_name, pk_type, has_tenant, has_status, extra_fields)
TABLES = [
    # Config tables (D03)
    ("cpq_config_rule", "CpqConfigRule", "ruleId", "Long", True, True, [
        ("ruleName", "String"),
        ("ruleType", "String"),
        ("modelId", "Long"),
        ("conditionExpr", "String"),  # TEXT -> String
        ("actionExpr", "String"),      # TEXT -> String  
        ("errorMessage", "String"),
        ("severity", "String"),
        ("priority", "Integer"),
        ("effectiveDate", "Date"),
        ("expiryDate", "Date"),
    ]),
    ("cpq_variant_bom", "CpqVariantBom", "variantId", "Long", True, False, [
        ("modelId", "Long"),
        ("sbomLineId", "Long"),
        ("materialCode", "String"),
        ("quantity", "BigDecimal"),
        ("effectivityCondition", "String"),  # TEXT -> String
        ("isDefault", "String"),
        ("sortOrder", "Integer"),
    ]),
    ("cpq_attribute_mapping", "CpqAttributeMapping", "mappingId", "Long", True, False, [
        ("modelId", "Long"),
        ("attrName", "String"),
        ("attrValue", "String"),
        ("materialCode", "String"),
        ("sbomLineId", "Long"),
        ("conditionExpr", "String"),
        ("sortOrder", "Integer"),
    ]),
    ("cpq_compatibility_matrix", "CpqCompatibilityMatrix", "matrixId", "Long", True, False, [
        ("sourceProductId", "Long"),
        ("targetProductId", "Long"),
        ("compatibilityType", "String"),
        ("conditionDesc", "String"),
    ]),
    ("cpq_attribute_option", "CpqAttributeOption", "optionId", "Long", True, False, [
        ("modelId", "Long"),
        ("attrName", "String"),
        ("optionCode", "String"),
        ("optionLabel", "String"),
        ("optionValue", "String"),
        ("isDefault", "String"),
        ("sortOrder", "Integer"),
    ]),
    # Bundle tables (D01)
    ("cpq_bundle", "CpqBundle", "bundleId", "Long", True, True, [
        ("modelId", "Long"),
        ("bundleType", "String"),
        ("pricingStrategy", "String"),
        ("bundleDiscountPct", "BigDecimal"),
        ("isActive", "String"),
        ("description", "String"),
    ]),
    ("cpq_bundle_option_group", "CpqBundleOptionGroup", "optionGroupId", "Long", True, True, [
        ("bundleId", "Long"),
        ("groupName", "String"),
        ("groupCode", "String"),
        ("minSelections", "Integer"),
        ("maxSelections", "Integer"),
        ("isRequired", "String"),
        ("sortOrder", "Integer"),
    ]),
    ("cpq_bundle_option", "CpqBundleOption", "optionId", "Long", True, True, [
        ("optionGroupId", "Long"),
        ("componentModelId", "Long"),
        ("quantity", "BigDecimal"),
        ("unit", "String"),
        ("isDefault", "String"),
        ("priceModifierType", "String"),
        ("priceModifierValue", "BigDecimal"),
        ("sortOrder", "Integer"),
    ]),
]

def gen_domain(table, prefix, pk, pk_type, tenant, status, fields):
    cls = f"""package {PKG}.domain;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;

import java.io.Serial;
"""
    for _, ftype in fields:
        if ftype == "BigDecimal":
            cls += "import java.math.BigDecimal;\n"
        elif ftype == "Date":
            cls += "import java.util.Date;\n"
    
    cls += f"""
/**
 * CPQ {"配置规则" if "rule" in prefix.lower() else "变体BOM" if "variant_bom" in table else "属性映射" if "attribute_map" in table else "兼容性矩阵" if "compat" in table else "属性选项" if "attribute_option" in table else "捆绑包" if prefix == "CpqBundle" else "捆绑选项组" if "OptionGroup" in prefix else "捆绑选项"} Domain
 *
 * @author CPQ Team
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("{table}")
public class {prefix} extends TenantEntity {{

    @Serial
    private static final long serialVersionUID = 1L;

    @TableId(value = "{table_to_col(pk)}")
    private {pk_type} {pk};
"""
    for fname, ftype in fields:
        col = table_to_col(fname)
        cls += f"""
    private {ftype} {fname};"""
    
    if status:
        # status is extra
        pass
    
    cls += f"""

    private String status;

    @TableLogic
    private String delFlag;
}}
"""
    return cls

def table_to_col(name):
    """CamelCase to snake_case for @TableId"""
    import re
    return re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()

def gen_bo(table, prefix, pk, pk_type, fields, pkg):
    imports = f"""package {pkg}.domain.bo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.dromara.common.tenant.core.TenantEntity;
import {pkg}.domain.{prefix};

import java.io.Serial;
"""
    for _, ftype in fields:
        if ftype == "BigDecimal":
            imports += "import java.math.BigDecimal;\n"
        elif ftype == "Date":
            imports += "import java.util.Date;\n"
    
    cls = f"""{imports}
@Data
@EqualsAndHashCode(callSuper = true)
@AutoMapper(target = {prefix}.class, reverseConvertGenerate = false)
public class {prefix}Bo extends TenantEntity {{
    @Serial
    private static final long serialVersionUID = 1L;
    private {pk_type} {pk};
"""
    for fname, ftype in fields:
        cls += f"    private {ftype} {fname};\n"
    
    cls += """    private String status;
}
"""
    return cls

def gen_vo(table, prefix, pk, pk_type, fields, pkg):
    imports = f"""package {pkg}.domain.vo;

import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;
import {pkg}.domain.{prefix};

import java.io.Serial;
import java.io.Serializable;
"""
    for _, ftype in fields:
        if ftype == "BigDecimal":
            imports += "import java.math.BigDecimal;\n"
        elif ftype == "Date":
            imports += "import java.util.Date;\n"
    
    cls = f"""{imports}
@Data
@AutoMapper(target = {prefix}.class, reverseConvertGenerate = true)
public class {prefix}Vo implements Serializable {{
    @Serial
    private static final long serialVersionUID = 1L;
    private {pk_type} {pk};
"""
    for fname, ftype in fields:
        cls += f"    private {ftype} {fname};\n"
    
    cls += """    private String status;
    private String tenantId;
    private java.util.Date createTime;
    private java.util.Date updateTime;
    private String remark;
}
"""
    return cls

def gen_mapper(table, prefix, pkg):
    return f"""package {pkg}.mapper;

import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import {pkg}.domain.{prefix};
import {pkg}.domain.vo.{prefix}Vo;

public interface {prefix}Mapper extends BaseMapperPlus<{prefix}, {prefix}Vo> {{
}}
"""

def gen_service(table, prefix, pkg):
    return f"""package {pkg}.service;

import {pkg}.domain.{prefix};
import {pkg}.domain.vo.{prefix}Vo;
import {pkg}.domain.bo.{prefix}Bo;

import java.util.List;

public interface I{prefix}Service {{
    List<{prefix}Vo> selectList({prefix}Bo bo);
    {prefix}Vo selectById(Long id);
    Boolean insert({prefix}Bo bo);
    Boolean update({prefix}Bo bo);
    Boolean delete(Long id);
}}
"""

def gen_service_impl(table, prefix, pkg):
    entity_l = prefix[0].lower() + prefix[1:]
    return f"""package {pkg}.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.ObjectUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.utils.MapstructUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import {pkg}.domain.{prefix};
import {pkg}.domain.bo.{prefix}Bo;
import {pkg}.domain.vo.{prefix}Vo;
import {pkg}.mapper.{prefix}Mapper;
import {pkg}.service.I{prefix}Service;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Service
public class {prefix}ServiceImpl implements I{prefix}Service {{

    private final {prefix}Mapper mapper;

    @Override
    public List<{prefix}Vo> selectList({prefix}Bo bo) {{
        LambdaQueryWrapper<{prefix}> qw = Wrappers.lambdaQuery();
        // query by status = '0' (normal), del_flag will be filtered by @TableLogic
        qw.eq({prefix}::getStatus, "0");
        // Add query conditions from BO if needed
        qw.orderByDesc({prefix}::getCreateTime);
        return mapper.selectVoList(qw);
    }}

    @Override
    public {prefix}Vo selectById(Long id) {{
        return mapper.selectVoById(id);
    }}

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean insert({prefix}Bo bo) {{
        {prefix} entity = MapstructUtils.convert(bo, {prefix}.class);
        int rows = mapper.insert(entity);
        return rows > 0;
    }}

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean update({prefix}Bo bo) {{
        {prefix} existing = mapper.selectById(bo.get{prefix[3:]}());
        if (ObjectUtil.isNull(existing)) {{
            throw new RuntimeException("记录不存在");
        }}
        {prefix} entity = MapstructUtils.convert(bo, {prefix}.class);
        int rows = mapper.updateById(entity);
        return rows > 0;
    }}

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Boolean delete(Long id) {{
        int rows = mapper.deleteById(id);
        return rows > 0;
    }}
}}
"""

def gen_controller(table, prefix, pk, pk_camel, url_path, pkg):
    bo = f"{prefix}Bo"
    vo = f"{prefix}Vo"
    srv = f"I{prefix}Service"
    srv_var = srv[1].lower() + srv[2:]
    
    title = "CPQ配置规则" if "rule" in prefix.lower() else "CPQ变体BOM" if "VariantBom" in prefix else "CPQ属性映射" if "AttributeMapping" in prefix else "CPQ兼容性矩阵" if "Compatibility" in prefix else "CPQ属性选项" if "AttributeOption" in prefix else "CPQ捆绑包" if prefix == "CpqBundle" else "CPQ捆绑选项组" if "OptionGroup" in prefix else "CPQ捆绑选项"
    
    return f"""package {pkg}.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.web.core.BaseController;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import {pkg}.domain.bo.{bo};
import {pkg}.domain.vo.{vo};
import {pkg}.service.{srv};
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("{url_path}")
public class {prefix}Controller extends BaseController {{

    private final {srv} {srv_var};

    @GetMapping("/list")
    public R<List<{vo}>> list({bo} bo) {{
        return R.ok({srv_var}.selectList(bo));
    }}

    @GetMapping("{{{pk_camel}}}")
    public R<{vo}> getInfo(@PathVariable Long {pk_camel}) {{
        return R.ok({srv_var}.selectById({pk_camel}));
    }}

    @Log(title = "{title}", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody {bo} bo) {{
        return toAjax({srv_var}.insert(bo));
    }}

    @Log(title = "{title}", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody {bo} bo) {{
        return toAjax({srv_var}.update(bo));
    }}

    @Log(title = "{title}", businessType = BusinessType.DELETE)
    @DeleteMapping("{{{pk_camel}}}")
    public R<Void> remove(@PathVariable Long {pk_camel}) {{
        return toAjax({srv_var}.delete({pk_camel}));
    }}
}}
"""

def get_url_path(prefix):
    if prefix == "CpqConfigRule": return "/cpq/config/rule"
    if prefix == "CpqVariantBom": return "/cpq/config/variantbom"
    if prefix == "CpqAttributeMapping": return "/cpq/config/attributemapping"
    if prefix == "CpqCompatibilityMatrix": return "/cpq/config/compatibility"
    if prefix == "CpqAttributeOption": return "/cpq/config/attributeoption"
    if prefix == "CpqBundle": return "/cpq/product/bundle"
    if prefix == "CpqBundleOptionGroup": return "/cpq/product/bundleoptiongroup"
    if prefix == "CpqBundleOption": return "/cpq/product/bundleoption"
    return ""

def get_pk_camel(prefix, pk):
    """Get camelCase PK name for URL path var"""
    return pk[0].lower() + pk[1:]

# ===== Execute =====
os.makedirs(SRC, exist_ok=True)
subdirs = ["domain", "domain/bo", "domain/vo", "mapper", "service", "service/impl", "controller"]
for d in subdirs:
    os.makedirs(os.path.join(SRC, d), exist_ok=True)

count = 0
for table, prefix, pk_camel, pk_type, tenant, status, fields in TABLES:
    pk_col = table_to_col(pk_camel)
    
    # Domain
    path = os.path.join(SRC, f"domain/{prefix}.java")
    with open(path, 'w') as f:
        f.write(gen_domain(table, prefix, pk_camel, pk_type, tenant, status, fields))
    count += 1
    
    # BO
    path = os.path.join(SRC, f"domain/bo/{prefix}Bo.java")
    with open(path, 'w') as f:
        f.write(gen_bo(table, prefix, pk_camel, pk_type, fields, PKG))
    count += 1
    
    # VO
    path = os.path.join(SRC, f"domain/vo/{prefix}Vo.java")
    with open(path, 'w') as f:
        f.write(gen_vo(table, prefix, pk_camel, pk_type, fields, PKG))
    count += 1
    
    # Mapper
    path = os.path.join(SRC, f"mapper/{prefix}Mapper.java")
    with open(path, 'w') as f:
        f.write(gen_mapper(table, prefix, PKG))
    count += 1
    
    # Service interface
    path = os.path.join(SRC, f"service/I{prefix}Service.java")
    with open(path, 'w') as f:
        f.write(gen_service(table, prefix, PKG))
    count += 1
    
    # Service impl
    path = os.path.join(SRC, f"service/impl/{prefix}ServiceImpl.java")
    with open(path, 'w') as f:
        f.write(gen_service_impl(table, prefix, PKG))
    count += 1
    
    # Controller
    url_path = get_url_path(prefix)
    path = os.path.join(SRC, f"controller/{prefix}Controller.java")
    with open(path, 'w') as f:
        f.write(gen_controller(table, prefix, pk_camel, pk_camel, url_path, PKG))
    count += 1

print(f"Generated {count} files (8 tables × 7 file types = {len(TABLES)*7} files)")

# Generate pom.xml for ruoyi-cpq-config module
pom_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.dromara</groupId>
        <artifactId>ruoyi-modules</artifactId>
        <version>5.6.1</version>
    </parent>

    <artifactId>ruoyi-cpq-config</artifactId>
    <version>${{revision}}</version>
    <packaging>jar</packaging>
    <name>ruoyi-cpq-config</name>
    <description>CPQ 配置引擎模块 — D03 配置规则+变体BOM+属性映射+兼容性矩阵+D01 Bundle</description>

    <dependencies>
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-core</artifactId>
        </dependency>
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-tenant</artifactId>
        </dependency>
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-mybatis</artifactId>
        </dependency>
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-log</artifactId>
        </dependency>
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.dromara</groupId>
            <artifactId>ruoyi-common-idempotent</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>

</project>
"""
with open(os.path.join(MODULE_PATH, "pom.xml"), 'w') as f:
    f.write(pom_xml)
print("pom.xml generated")
print("Done!")
