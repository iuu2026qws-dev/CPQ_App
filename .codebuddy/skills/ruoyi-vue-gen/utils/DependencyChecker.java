package com.hruingerai.utils;

import com.hruingerai.common.utils.StringUtils;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashSet;
import java.util.Set;

/**
 * 依赖检查器
 *
 * 用于检查项目中是否包含指定的依赖，并自动添加缺失的依赖
 *
 * @author ruoyi
 * @date 2026-03-29
 */
public class DependencyChecker
{
    /**
     * 检查项目是否包含 Lombok 依赖
     *
     * @param projectPath 项目路径
     * @return 是否包含 Lombok 依赖
     */
    public static boolean checkLombokDependency(String projectPath)
    {
        return checkDependency(projectPath, "lombok");
    }

    /**
     * 检查项目是否包含 Hutool 依赖
     *
     * @param projectPath 项目路径
     * @return 是否包含 Hutool 依赖
     */
    public static boolean checkHutoolDependency(String projectPath)
    {
        return checkDependency(projectPath, "hutool");
    }

    /**
     * 检查项目是否包含指定依赖
     *
     * @param projectPath 项目路径
     * @param dependencyName 依赖名称
     * @return 是否包含依赖
     */
    private static boolean checkDependency(String projectPath, String dependencyName)
    {
        // 检查 pom.xml 文件
        File pomFile = new File(projectPath, "pom.xml");
        if (!pomFile.exists())
        {
            return false;
        }

        try
        {
            String content = Files.readString(pomFile.toPath());
            return content.toLowerCase().contains(dependencyName.toLowerCase());
        }
        catch (IOException e)
        {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 添加 Lombok 依赖到 pom.xml
     *
     * @param projectPath 项目路径
     * @return 是否添加成功
     */
    public static boolean addLombokDependency(String projectPath)
    {
        String dependency = """
                <!-- Lombok -->
                <dependency>
                    <groupId>org.projectlombok</groupId>
                    <artifactId>lombok</artifactId>
                    <version>1.18.30</version>
                </dependency>
                """;
        return addDependency(projectPath, dependency);
    }

    /**
     * 添加 Hutool 依赖到 pom.xml
     *
     * @param projectPath 项目路径
     * @return 是否添加成功
     */
    public static boolean addHutoolDependency(String projectPath)
    {
        String dependency = """
                <!-- Hutool -->
                <dependency>
                    <groupId>cn.hutool</groupId>
                    <artifactId>hutool-all</artifactId>
                    <version>5.8.26</version>
                </dependency>
                """;
        return addDependency(projectPath, dependency);
    }

    /**
     * 添加依赖到 pom.xml
     *
     * @param projectPath 项目路径
     * @param dependency 依赖配置
     * @return 是否添加成功
     */
    private static boolean addDependency(String projectPath, String dependency)
    {
        File pomFile = new File(projectPath, "pom.xml");
        if (!pomFile.exists())
        {
            return false;
        }

        try
        {
            String content = Files.readString(pomFile.toPath());
            int dependenciesIndex = content.indexOf("<dependencies>");
            if (dependenciesIndex == -1)
            {
                return false;
            }

            // 在 </dependencies> 标签前插入依赖
            int endIndex = content.indexOf("</dependencies>");
            if (endIndex == -1)
            {
                return false;
            }

            String newContent = content.substring(0, endIndex) + dependency + content.substring(endIndex);
            Files.writeString(pomFile.toPath(), newContent);
            return true;
        }
        catch (IOException e)
        {
            e.printStackTrace();
            return false;
        }
    }
}
