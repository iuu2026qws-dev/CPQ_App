package com.hruingerai.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Java 性能优化工具类（V4.0）
 *
 * 优化策略：
 * 1. 集合类优化：ArrayList、HashMap、初始容量
 * 2. 字符串处理优化：StringBuilder、String.join()
 * 3. 缓存策略优化：@Cacheable、@CachePut、@CacheEvict、Redis
 * 4. SQL 查询优化：避免 SELECT *、使用索引、LIMIT、批量操作
 * 5. 并发处理优化：线程池、ReadWriteLock、ConcurrentHashMap
 *
 * @author HRuinger.
 * @date 2026-03-29
 * @version 4.0.0
 */
public class PerformanceOptimizer {

    /**
     * 性能优化建议
     */
    public static class OptimizationSuggestion {
        /**
         * 优化类型
         */
        private OptimizationType type;

        /**
         * 优化描述
         */
        private String description;

        /**
         * 优化前
         */
        private String before;

        /**
         * 优化后
         */
        private String after;

        /**
         * 性能提升百分比
         */
        private int improvementPercentage;

        // Getters and Setters
        public OptimizationType getType() { return type; }
        public void setType(OptimizationType type) { this.type = type; }

        public String getDescription() { return description; }
        public void setDescription(String description) { return description; }

        public String getBefore() { return before; }
        public void setBefore(String before) { this.before = before; }

        public String getAfter() { return after; }
        public void setAfter(String after) { this.after = after; }

        public int getImprovementPercentage() { return improvementPercentage; }
        public void setImprovementPercentage(int improvementPercentage) {
            this.improvementPercentage = improvementPercentage;
        }
    }

    /**
     * 优化类型
     */
    public enum OptimizationType {
        /**
         * 集合类优化
         */
        COLLECTION,

        /**
         * 字符串处理优化
         */
        STRING,

        /**
         * 缓存策略优化
         */
        CACHE,

        /**
         * SQL 查询优化
         */
        SQL,

        /**
         * 并发处理优化
         */
        CONCURRENCY
    }

    /**
     * 获取集合类初始容量
     *
     * @param expectedSize 期望大小
     * @param isArrayList 是否为 ArrayList
     * @return 推荐的初始容量
     */
    public static int getCollectionInitialCapacity(int expectedSize, boolean isArrayList) {
        if (isArrayList) {
            // ArrayList 的默认扩容策略：newCapacity = oldCapacity + (oldCapacity >> 1)
            // 即扩容 50%，为了避免多次扩容，设置为期望大小 + 期望大小/2
            return expectedSize + (expectedSize >> 1);
        } else {
            // HashMap 的默认负载因子是 0.75
            // 容量 = 期望大小 / 负载因子 + 1
            return (int) (expectedSize / 0.75f) + 1;
        }
    }

    /**
     * 优化字符串拼接
     *
     * @param strings 要拼接的字符串数组
     * @return 拼接后的字符串
     */
    public static String optimizedStringJoin(String... strings) {
        // 使用 String.join() 代替循环拼接
        return String.join("", strings);
    }

    /**
     * 优化字符串拼接（带分隔符）
     *
     * @param delimiter 分隔符
     * @param strings 要拼接的字符串数组
     * @return 拼接后的字符串
     */
    public static String optimizedStringJoinWithDelimiter(String delimiter, String... strings) {
        // 使用 String.join() 代替循环拼接
        return String.join(delimiter, strings);
    }

    /**
     * 创建优化的 ArrayList
     *
     * @param expectedSize 期望大小
     * @return 优化后的 ArrayList
     */
    public static <T> ArrayList<T> createOptimizedArrayList(int expectedSize) {
        // 设置合理的初始容量，减少扩容开销
        int initialCapacity = getCollectionInitialCapacity(expectedSize, true);
        return new ArrayList<>(initialCapacity);
    }

    /**
     * 创建优化的 HashMap
     *
     * @param expectedSize 期望大小
     * @return 优化后的 HashMap
     */
    public static <K, V> HashMap<K, V> createOptimizedHashMap(int expectedSize) {
        // 设置合理的初始容量，减少扩容开销
        int initialCapacity = getCollectionInitialCapacity(expectedSize, false);
        return new HashMap<>(initialCapacity);
    }

    /**
     * 生成缓存注解
     *
     * @param cacheName 缓存名称
     * @param keyGenerator 键生成器（可选）
     * @return 缓存注解字符串
     */
    public static String generateCacheableAnnotation(String cacheName, String keyGenerator) {
        StringBuilder sb = new StringBuilder("@Cacheable(value = \"");
        sb.append(cacheName).append("\"");

        if (keyGenerator != null && !keyGenerator.isEmpty()) {
            sb.append(", keyGenerator = \"").append(keyGenerator).append("\"");
        }

        sb.append(")");
        return sb.toString();
    }

    /**
     * 生成缓存更新注解
     *
     * @param cacheName 缓存名称
     * @param keyGenerator 键生成器（可选）
     * @return 缓存更新注解字符串
     */
    public static String generateCachePutAnnotation(String cacheName, String keyGenerator) {
        StringBuilder sb = new StringBuilder("@CachePut(value = \"");
        sb.append(cacheName).append("\"");

        if (keyGenerator != null && !keyGenerator.isEmpty()) {
            sb.append(", keyGenerator = \"").append(keyGenerator).append("\"");
        }

        sb.append(")");
        return sb.toString();
    }

    /**
     * 生成缓存清除注解
     *
     * @param cacheName 缓存名称
     * @param allEntries 是否清除所有条目
     * @return 缓存清除注解字符串
     */
    public static String generateCacheEvictAnnotation(String cacheName, boolean allEntries) {
        StringBuilder sb = new StringBuilder("@CacheEvict(value = \"");
        sb.append(cacheName).append("\"");

        if (allEntries) {
            sb.append(", allEntries = true");
        }

        sb.append(")");
        return sb.toString();
    }

    /**
     * 优化 SQL 查询
     *
     * @param originalSQL 原始 SQL
     * @param fields 指定的字段列表
     * @return 优化后的 SQL
     */
    public static String optimizeSQL(String originalSQL, List<String> fields) {
        String optimizedSQL = originalSQL.trim();

        // 检查是否包含 SELECT *
        if (optimizedSQL.toUpperCase().contains("SELECT *")) {
            if (fields != null && !fields.isEmpty()) {
                // 替换 SELECT * 为 SELECT field1, field2, ...
                String fieldsStr = String.join(", ", fields);
                optimizedSQL = optimizedSQL.replaceFirst("(?i)SELECT \\*", "SELECT " + fieldsStr);
            }
        }

        return optimizedSQL;
    }

    /**
     * 生成批量插入 SQL
     *
     * @param tableName 表名
     * @param fields 字段列表
     * @param batchSize 批量大小
     * @return 批量插入 SQL
     */
    public static String generateBatchInsertSQL(String tableName, List<String> fields, int batchSize) {
        StringBuilder sb = new StringBuilder();

        sb.append("INSERT INTO `").append(tableName).append("` (");

        // 字段列表
        sb.append(String.join(", ", fields));

        sb.append(") VALUES ");

        // 值占位符
        StringBuilder values = new StringBuilder();
        for (int i = 0; i < fields.size(); i++) {
            if (i > 0) {
                values.append(", ");
            }
            values.append("?");
        }

        // 重复批量次数
        for (int i = 0; i < batchSize; i++) {
            if (i > 0) {
                sb.append(", ");
            }
            sb.append("(").append(values).append(")");
        }

        return sb.toString();
    }

    /**
     * 获取性能优化建议
     *
     * @return 优化建议列表
     */
    public static List<OptimizationSuggestion> getOptimizationSuggestions() {
        List<OptimizationSuggestion> suggestions = new ArrayList<>();

        // 集合类优化建议
        suggestions.add(createCollectionOptimization());
        suggestions.add(createHashMapOptimization());
        suggestions.add(createInitialCapacityOptimization());

        // 字符串处理优化建议
        suggestions.add(createStringBuilderOptimization());
        suggestions.add(createStringJoinOptimization());

        // 缓存策略优化建议
        suggestions.add(createCacheableOptimization());
        suggestions.add(createCachePutOptimization());
        suggestions.add(createCacheEvictOptimization());

        // SQL 查询优化建议
        suggestions.add(createSelectFieldOptimization());
        suggestions.add(createIndexOptimization());
        suggestions.add(createLimitOptimization());
        suggestions.add(createBatchOperationOptimization());

        // 并发处理优化建议
        suggestions.add(createThreadPoolOptimization());
        suggestions.add(createReadWriteLockOptimization());
        suggestions.add(createConcurrentHashMapOptimization());

        return suggestions;
    }

    /**
     * 集合类优化建议
     */
    private static OptimizationSuggestion createCollectionOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.COLLECTION);
        suggestion.setDescription("优先使用 ArrayList 代替 LinkedList");
        suggestion.setBefore("LinkedList<String> list = new LinkedList<>();");
        suggestion.setAfter("ArrayList<String> list = new ArrayList<>();");
        suggestion.setImprovementPercentage(100);
        return suggestion;
    }

    /**
     * HashMap 优化建议
     */
    private static OptimizationSuggestion createHashMapOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.COLLECTION);
        suggestion.setDescription("优先使用 HashMap 代替 TreeMap");
        suggestion.setBefore("TreeMap<String, Object> map = new TreeMap<>();");
        suggestion.setAfter("HashMap<String, Object> map = new HashMap<>();");
        suggestion.setImprovementPercentage(200);
        return suggestion;
    }

    /**
     * 初始容量优化建议
     */
    private static OptimizationSuggestion createInitialCapacityOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.COLLECTION);
        suggestion.setDescription("设置合理的集合初始容量");
        suggestion.setBefore("ArrayList<String> list = new ArrayList<>();");
        suggestion.setAfter("ArrayList<String> list = new ArrayList<>(expectedSize + (expectedSize >> 1));");
        suggestion.setImprovementPercentage(50);
        return suggestion;
    }

    /**
     * StringBuilder 优化建议
     */
    private static OptimizationSuggestion createStringBuilderOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.STRING);
        suggestion.setDescription("循环中使用 StringBuilder 代替 String 拼接");
        suggestion.setBefore("String result = \"\";\n" +
                           "for (String s : list) {\n" +
                           "    result += s;\n" +
                           "}");
        suggestion.setAfter("StringBuilder sb = new StringBuilder();\n" +
                          "for (String s : list) {\n" +
                          "    sb.append(s);\n" +
                          "}\n" +
                          "String result = sb.toString();");
        suggestion.setImprovementPercentage(500);
        return suggestion;
    }

    /**
     * String.join() 优化建议
     */
    private static OptimizationSuggestion createStringJoinOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.STRING);
        suggestion.setDescription("使用 String.join() 代替循环拼接");
        suggestion.setBefore("StringBuilder sb = new StringBuilder();\n" +
                          "for (int i = 0; i < list.size(); i++) {\n" +
                          "    if (i > 0) sb.append(\", \");\n" +
                          "    sb.append(list.get(i));\n" +
                          "}\n" +
                          "String result = sb.toString();");
        suggestion.setAfter("String result = String.join(\", \", list);");
        suggestion.setImprovementPercentage(300);
        return suggestion;
    }

    /**
     * @Cacheable 优化建议
     */
    private static OptimizationSuggestion createCacheableOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.CACHE);
        suggestion.setDescription("查询方法使用 @Cacheable 注解");
        suggestion.setBefore("@Override\n" +
                           "public User getUserById(Long id) {\n" +
                           "    return userMapper.selectById(id);\n" +
                           "}");
        suggestion.setAfter("@Override\n" +
                          "@Cacheable(value = \"user\", key = \"#id\")\n" +
                          "public User getUserById(Long id) {\n" +
                          "    return userMapper.selectById(id);\n" +
                          "}");
        suggestion.setImprovementPercentage(90);
        return suggestion;
    }

    /**
     * @CachePut 优化建议
     */
    private static OptimizationSuggestion createCachePutOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.CACHE);
        suggestion.setDescription("更新方法使用 @CachePut 注解");
        suggestion.setBefore("@Override\n" +
                           "public int updateUser(User user) {\n" +
                           "    return userMapper.updateById(user);\n" +
                           "}");
        suggestion.setAfter("@Override\n" +
                          "@CachePut(value = \"user\", key = \"#user.id\")\n" +
                          "public int updateUser(User user) {\n" +
                          "    return userMapper.updateById(user);\n" +
                          "}");
        suggestion.setImprovementPercentage(90);
        return suggestion;
    }

    /**
     * @CacheEvict 优化建议
     */
    private static OptimizationSuggestion createCacheEvictOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.CACHE);
        suggestion.setDescription("删除方法使用 @CacheEvict 注解");
        suggestion.setBefore("@Override\n" +
                           "public int deleteUser(Long id) {\n" +
                           "    return userMapper.deleteById(id);\n" +
                           "}");
        suggestion.setAfter("@Override\n" +
                          "@CacheEvict(value = \"user\", key = \"#id\")\n" +
                          "public int deleteUser(Long id) {\n" +
                          "    return userMapper.deleteById(id);\n" +
                          "}");
        suggestion.setImprovementPercentage(90);
        return suggestion;
    }

    /**
     * SELECT 字段优化建议
     */
    private static OptimizationSuggestion createSelectFieldOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.SQL);
        suggestion.setDescription("避免 SELECT *，明确指定需要的字段");
        suggestion.setBefore("SELECT * FROM user WHERE id = #{id}");
        suggestion.setAfter("SELECT id, user_name, nick_name, email FROM user WHERE id = #{id}");
        suggestion.setImprovementPercentage(50);
        return suggestion;
    }

    /**
     * 索引优化建议
     */
    private static OptimizationSuggestion createIndexOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.SQL);
        suggestion.setDescription("在 WHERE 条件中使用索引字段");
        suggestion.setBefore("SELECT * FROM user WHERE nick_name LIKE #{nickName}");
        suggestion.setAfter("SELECT id, user_name, nick_name FROM user WHERE user_name LIKE #{userName}");
        suggestion.setImprovementPercentage(1000);
        return suggestion;
    }

    /**
     * LIMIT 优化建议
     */
    private static OptimizationSuggestion createLimitOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.SQL);
        suggestion.setDescription("使用 LIMIT 限制返回结果");
        suggestion.setBefore("SELECT * FROM user ORDER BY create_time DESC");
        suggestion.setAfter("SELECT id, user_name, nick_name FROM user ORDER BY create_time DESC LIMIT 10");
        suggestion.setImprovementPercentage(90);
        return suggestion;
    }

    /**
     * 批量操作优化建议
     */
    private static OptimizationSuggestion createBatchOperationOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.SQL);
        suggestion.setDescription("使用批量操作代替循环单条");
        suggestion.setBefore("for (User user : users) {\n" +
                           "    userMapper.insert(user);\n" +
                           "}");
        suggestion.setAfter("userMapper.batchInsert(users);");
        suggestion.setImprovementPercentage(500);
        return suggestion;
    }

    /**
     * 线程池优化建议
     */
    private static OptimizationSuggestion createThreadPoolOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.CONCURRENCY);
        suggestion.setDescription("使用线程池代替直接创建线程");
        suggestion.setBefore("for (int i = 0; i < 10; i++) {\n" +
                           "    new Thread(() -> doTask()).start();\n" +
                           "}");
        suggestion.setAfter("ExecutorService executor = Executors.newFixedThreadPool(10);\n" +
                          "for (int i = 0; i < 10; i++) {\n" +
                          "    executor.submit(() -> doTask());\n" +
                          "}\n" +
                          "executor.shutdown();");
        suggestion.setImprovementPercentage(300);
        return suggestion;
    }

    /**
     * ReadWriteLock 优化建议
     */
    private static OptimizationSuggestion createReadWriteLockOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.CONCURRENCY);
        suggestion.setDescription("使用 ReadWriteLock 代替 synchronized");
        suggestion.setBefore("public synchronized List<User> getUsers() {\n" +
                           "    return users;\n" +
                           "}");
        suggestion.setAfter("private final ReadWriteLock lock = new ReentrantReadWriteLock();\n\n" +
                          "public List<User> getUsers() {\n" +
                          "    lock.readLock().lock();\n" +
                          "    try {\n" +
                          "        return users;\n" +
                          "    } finally {\n" +
                          "        lock.readLock().unlock();\n" +
                          "    }\n" +
                          "}");
        suggestion.setImprovementPercentage(50);
        return suggestion;
    }

    /**
     * ConcurrentHashMap 优化建议
     */
    private static OptimizationSuggestion createConcurrentHashMapOptimization() {
        OptimizationSuggestion suggestion = new OptimizationSuggestion();
        suggestion.setType(OptimizationType.CONCURRENCY);
        suggestion.setDescription("使用 ConcurrentHashMap 等并发集合");
        suggestion.setBefore("Map<String, Object> map = new HashMap<>();\n" +
                           "// synchronized 块或使用其他同步机制");
        suggestion.setAfter("Map<String, Object> map = new ConcurrentHashMap<>();\n" +
                          "// 无需手动同步");
        suggestion.setImprovementPercentage(200);
        return suggestion;
    }
}
