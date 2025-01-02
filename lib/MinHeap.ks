runOncePath("/KOSY/lib/kobject.ks").

function MinHeap {
    local self is Object():extend.
    self:setClassName("MinHeap").
    
    local heap_list is list(0).  // Using 0 as sentinel
    local count is 0.
    
    // Helper functions
    local function bubble_up {
        parameter index.
        
        until index <= 1 or heap_list[index]:value:get() >= heap_list[floor(index/2)]:value:get() {
            // Swap elements
            local temp is heap_list[index].
            set heap_list[index] to heap_list[floor(index/2)].
            set heap_list[floor(index/2)] to temp.
            set index to floor(index/2).
        }
    }
    
    local function bubble_down {
        parameter index.
        
        until 2*index > count {
            local min_child is get_min_child(index).
            if heap_list[index]:value:get() > heap_list[min_child]:value:get() {
                // Swap elements
                local temp is heap_list[index].
                set heap_list[index] to heap_list[min_child].
                set heap_list[min_child] to temp.
                set index to min_child.
            } else {
                break.
            }
        }
    }
    
    local function get_min_child {
        parameter index.
        
        if 2*index + 1 > count {
            return 2*index.
        }
        
        if heap_list[2*index]:value:get() < heap_list[2*index + 1]:value:get() {
            return 2*index.
        }
        return 2*index + 1.
    }
    
    // Public methods
    self:public("insert", {
        parameter element.
        heap_list:add(element).
        set count to count + 1.
        bubble_up(count).
    }).
    
    self:public("extract_min", {
        if count = 0 {
            return 0.
        }
        
        local min_element is heap_list[1].
        set heap_list[1] to heap_list[count].
        heap_list:remove(count).
        set count to count - 1.
        
        if count > 0 {
            bubble_down(1).
        }
        
        return min_element.
    }).
    
    self:public("size", {
        return count.
    }).

    self:public("isEmpty",{
        return count = 0.
    }).
    
    return defineObject(self).
}