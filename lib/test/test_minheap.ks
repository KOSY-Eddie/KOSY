runOncePath("/KOSY/lib/test/UnitTest.ks").
runOncePath("/KOSY/lib/minheap.ks").

// Test item with value:get()
function HeapItem {
    parameter val.
    local self is Object():extend.
    
    self:public("value", val).
    
    return defineObject(self).
}

function MinHeapTests {
    local self is UnitTest():extend().
    
    // Basic Operations
    self:test("Basic Operations", {
        local heap is MinHeap():new.
        
        // Test empty heap
        self:assert(heap:isEmpty(), "New heap is empty").
        self:assertEqual(heap:size(), 0, "Empty heap size is 0").
        self:assertEqual(heap:extract_min(), 0, "Extract from empty heap returns 0").
        
        // Single item operations
        heap:insert(HeapItem(5):new).
        self:assertEqual(heap:size(), 1, "Size is 1 after insertion").
        self:assert(not heap:isEmpty(), "Heap not empty after insertion").
        
        local extracted is heap:extract_min().
        self:assertEqual(extracted:value:get(), 5, "Extracted correct value").
        self:assert(heap:isEmpty(), "Heap empty after extraction").
    }).
    
    // Multiple Items
    self:test("Multiple Items", {
        local heap is MinHeap():new.
        
        // Insert multiple items
        heap:insert(HeapItem(5):new).
        heap:insert(HeapItem(3):new).
        heap:insert(HeapItem(7):new).
        
        self:assertEqual(heap:size(), 3, "Size correct after multiple inserts").
        
        // Extract and verify order
        local first is heap:extract_min():value:get().
        local second is heap:extract_min():value:get().
        local third is heap:extract_min():value:get().
        
        self:assertEqual(first, 3, "First extraction is minimum").
        self:assertEqual(second, 5, "Second extraction is next minimum").
        self:assertEqual(third, 7, "Third extraction is maximum").
    }).
    
    // Stress Test
    self:test("Stress Test", {
        local heap is MinHeap():new.
        local values is list().
        
        // Insert many items
        from { local i is 1. } until i > 20 step { set i to i + 1. } do {
            heap:insert(HeapItem(i):new).
            values:add(i).
        }.
        
        self:assertEqual(heap:size(), 20, "All items inserted").
        
        // Extract all and verify ordering
        from { local i is 1. } until i > 20 step { set i to i + 1. } do {
            local val is heap:extract_min():value:get().
            self:assertEqual(val, i, "Extracted in correct order").
        }.
        
        self:assert(heap:isEmpty(), "Heap empty after all extractions").
    }).
    
    return defineObject(self).
}

// Run the tests
local runner is UnitTestRunner():new.
runner:addSuite(MinHeapTests():new).
runner:runAll().
