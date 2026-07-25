package com.hruingerai.utils;

import java.sql.*;

/**
 * 数据库工具类
 *
 * @author HRuinger.
 * @date 2026-03-29
 */
public class DbUtils
{
    private static Connection connection;
    private static String url;
    private static String username;
    private static String password;

    /**
     * 初始化数据库连接
     *
     * @param dbUrl 数据库URL
     * @param dbUsername 用户名
     * @param dbPassword 密码
     * @throws SQLException SQL异常
     */
    public static void init(String dbUrl, String dbUsername, String dbPassword) throws SQLException
    {
        url = dbUrl;
        username = dbUsername;
        password = dbPassword;
        connection = DriverManager.getConnection(url, username, password);
        System.out.println("数据库连接成功！");
    }

    /**
     * 获取数据库连接
     *
     * @return 数据库连接
     * @throws SQLException SQL异常
     */
    public static Connection getConnection() throws SQLException
    {
        if (connection == null || connection.isClosed())
        {
            if (url != null && username != null && password != null)
            {
                connection = DriverManager.getConnection(url, username, password);
            }
            else
            {
                throw new SQLException("数据库未初始化，请先调用 init() 方法");
            }
        }
        return connection;
    }

    /**
     * 关闭数据库连接
     *
     * @throws SQLException SQL异常
     */
    public static void close() throws SQLException
    {
        if (connection != null && !connection.isClosed())
        {
            connection.close();
            System.out.println("数据库连接已关闭！");
        }
    }

    /**
     * 执行 SQL 查询
     *
     * @param sql SQL 语句
     * @return 结果集
     * @throws SQLException SQL异常
     */
    public static ResultSet executeQuery(String sql) throws SQLException
    {
        Statement stmt = getConnection().createStatement();
        return stmt.executeQuery(sql);
    }

    /**
     * 执行 SQL 更新
     *
     * @param sql SQL 语句
     * @return 影响行数
     * @throws SQLException SQL异常
     */
    public static int executeUpdate(String sql) throws SQLException
    {
        Statement stmt = getConnection().createStatement();
        return stmt.executeUpdate(sql);
    }

    /**
     * 执行批量 SQL
     *
     * @param sqlList SQL 语句列表
     * @return 影响行数数组
     * @throws SQLException SQL异常
     */
    public static int[] executeBatch(String[] sqlList) throws SQLException
    {
        Statement stmt = getConnection().createStatement();
        for (String sql : sqlList)
        {
            stmt.addBatch(sql);
        }
        return stmt.executeBatch();
    }

    /**
     * 测试数据库连接
     *
     * @return 是否连接成功
     */
    public static boolean testConnection()
    {
        try
        {
            return connection != null && !connection.isClosed() && connection.isValid(5);
        }
        catch (SQLException e)
        {
            return false;
        }
    }

    /**
     * 获取数据库信息
     *
     * @return 数据库信息
     * @throws SQLException SQL异常
     */
    public static String getDatabaseInfo() throws SQLException
    {
        Connection conn = getConnection();
        DatabaseMetaData metaData = conn.getMetaData();
        
        StringBuilder info = new StringBuilder();
        info.append("数据库产品名称：").append(metaData.getDatabaseProductName()).append("\n");
        info.append("数据库产品版本：").append(metaData.getDatabaseProductVersion()).append("\n");
        info.append("驱动名称：").append(metaData.getDriverName()).append("\n");
        info.append("驱动版本：").append(metaData.getDriverVersion()).append("\n");
        info.append("URL：").append(metaData.getURL()).append("\n");
        info.append("用户名：").append(metaData.getUserName()).append("\n");
        
        return info.toString();
    }
}
