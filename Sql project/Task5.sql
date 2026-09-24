
-- Rank delivery agents (per route) by on-time delivery percentage-----------------------------------------------

WITH Agent_Performance AS (
    SELECT
        Route_ID,
        Agent_ID,
        COUNT(*) AS Total_Shipments,
        SUM(CASE WHEN Delay_Hours = 0 THEN 1 ELSE 0 END) AS OnTime_Shipments
    FROM shipments
    GROUP BY Route_ID, Agent_ID
),
Agent_Rank AS (
    SELECT
        Route_ID,
        Agent_ID,
        Total_Shipments,
        OnTime_Shipments,
        ROUND((OnTime_Shipments / Total_Shipments) * 100, 2) AS OnTime_Percentage,
        RANK() OVER (
            PARTITION BY Route_ID
            ORDER BY (OnTime_Shipments / Total_Shipments) DESC
        ) AS Route_Rank
    FROM Agent_Performance
)
SELECT *
FROM Agent_Rank
ORDER BY Route_ID, Route_Rank;

-- Find agents whose on-time % is below 85%.--------------------------------------------------------------------------

WITH Agent_Performance AS (
    SELECT
        Agent_ID,
        COUNT(*) AS Total_Shipments,
        SUM(CASE WHEN Delay_Hours = 0 THEN 1 ELSE 0 END) AS OnTime_Shipments
    FROM shipments
    GROUP BY Agent_ID
)
SELECT
    Agent_ID,
    Total_Shipments,
    OnTime_Shipments,
    ROUND((OnTime_Shipments / Total_Shipments) * 100, 2) AS OnTime_Percentage
FROM Agent_Performance
WHERE (OnTime_Shipments / Total_Shipments) < 0.85
ORDER BY OnTime_Percentage;

-- Compare the average rating and experience (in years) of the top 5 vs bottom 5 agents using subqueries.------------------------------------------

SELECT
    ranked.Agent_Group,
    ROUND(AVG(a.Avg_Rating), 2) AS Avg_Rating,
    ROUND(AVG(a.Experience_Years), 2) AS Avg_Experience_Years
FROM delivery_agents a
JOIN (
        -- Top 5 Agents by On-Time %
        SELECT Agent_ID, 'Top 5' AS Agent_Group
        FROM (
                SELECT
                    Agent_ID,
                    SUM(CASE WHEN Delay_Hours = 0 THEN 1 ELSE 0 END) / COUNT(*) AS OnTime_Rate
                FROM shipments
                GROUP BY Agent_ID
                ORDER BY OnTime_Rate DESC
                LIMIT 5
        ) t
        
        UNION ALL
        
        -- Bottom 5 Agents by On-Time %
        SELECT Agent_ID, 'Bottom 5' AS Agent_Group
        FROM (
                SELECT
                    Agent_ID,
                    SUM(CASE WHEN Delay_Hours = 0 THEN 1 ELSE 0 END) / COUNT(*) AS OnTime_Rate
                FROM shipments
                GROUP BY Agent_ID
                ORDER BY OnTime_Rate ASC
                LIMIT 5
        ) b
) ranked
ON a.Agent_ID = ranked.Agent_ID
GROUP BY ranked.Agent_Group;

-- Suggest training or workload balancing strategies for low-performing agents based on insights.--------------------------------

/* 1. Identify why agents are underperforming
     Low experience + high delays → Skill gap
     High experience + high delays → Overloaded routes
     Low rating + low on-time % → Customer handling or motivation issue
     
2. Training strategies
    Pair low-performing agents with top agents for mentoring
    Use  top 5 agents to train bottom 5 agents
    Provide route-specific training for difficult routes
    Train agents on:
	Route planning
    Time management
    Customer handling
    
3. Workload balancing
    Assign long and high-volume routes to high-performing agents
    Assign simpler routes to low-performing agents
    Reduce daily shipment load for weak agents
    Increase shipment load for strong agents
    
4. Use ratings with performance
    Low rating + low on-time = high risk agent
	Put these agents on fewer and simpler deliveries
    Make training mandatory for them
    
5. Incentive-based improvement
    On-time > 95% → Bonus & priority routes
    On-time 85–95% → Normal workload
    On-time < 85% → Training + reduced workload */



