package org.dromara.system.service;

import java.util.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.R;
import org.dromara.system.domain.CpqPlant;
import org.dromara.system.mapper.CpqPlantMapper;
import org.springframework.stereotype.Service;

@Slf4j @Service @RequiredArgsConstructor
public class PlantAllocationService {
    private final CpqPlantMapper plantMapper;

    public R<Map<String,Object>> allocate(Long productId, int quantity, String priorityStrategy) {
        log.info("[Allocation] product={}, qty={}, strategy={}", productId, quantity, priorityStrategy);
        List<CpqPlant> plants = plantMapper.selectList(null);
        Map<String,Object> result = new HashMap<>();
        List<Map<String,Object>> allocations = new ArrayList<>();
        int remaining = quantity;
        for (CpqPlant plant : plants) {
            if ("0".equals(plant.getStatus())) {
                int alloc = Math.min(remaining, plant.getCapacityPerDay() != null ? plant.getCapacityPerDay() / 10 : 10);
                allocations.add(Map.of("plantCode", plant.getPlantCode(), "plantName", plant.getPlantName(), "allocated", alloc));
                remaining -= alloc;
                if (remaining <= 0) break;
            }
        }
        result.put("allocations", allocations);
        result.put("totalAllocated", quantity - remaining);
        result.put("unallocated", Math.max(0, remaining));
        return R.ok(result);
    }
}
