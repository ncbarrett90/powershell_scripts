import time
import math
import subprocess
import re

def get_terminal_dimensions():
    """
    Execute 'mode con' command and parse the output to extract
    the number of columns and lines of the current terminal.
    
    Returns:
        tuple: (columns, lines) or (None, None) if parsing fails
    """
    try:
        # Execute the mode con command
        result = subprocess.run('mode con', 
                      shell=True,
                      capture_output=True, 
                      text=True, 
                      check=True)
        
        output = result.stdout

        # Parse the output using regex patterns
        # Look for patterns like "Columns: 120" and "Lines: 30"
        columns_match = re.search(r'Columns:\s*(\d+)', output, re.IGNORECASE)
        lines_match = re.search(r'Lines:\s*(\d+)', output, re.IGNORECASE)
        
        columns = int(columns_match.group(1)) if columns_match else None
        lines = int(lines_match.group(1)) if lines_match else None
        print (columns, lines)
        return columns, lines
        
    except subprocess.CalledProcessError as e:
        print(f"Error executing 'mode con': {e}")
        return None, None
    except Exception as e:
        print(f"Error parsing output: {e}")
        return None, None
    
num_cols, num_rows = get_terminal_dimensions()
screen = [[' ' for _ in range(num_cols)] for _ in range(num_rows)]
cleared_screen = [[' ' for _ in range(num_cols)] for _ in range(num_rows)]

class vec3:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z

    def print_vector(self):
        print(self.x,self.y,self.z)

class vec2:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def print_vector(self):
        print(self.x,self.y)

midpoint = vec2(1,1)

cube_vertices = [
    vec3(-1,-1,-1), # 0
    vec3(-1,1,-1), # 1
    vec3(1,1,-1), # 2
    vec3(1,-1,-1), # 3
    vec3(1,1,1), # 4
    vec3(1,-1,1), # 5
    vec3(-1,-1,1), # 6
    vec3(-1,1,1), # 7
] 

cube_triangles = [
    # front face
    [0,1,2],
    [0,2,3],
    # right face
    [3,2,4],
    [3,4,5],
    # back face
    [5,4,7],
    [5,7,6],
    # left face
    [6,7,1],
    [6,1,0],
    # top face
    [6,0,3],
    [6,3,5],
    # bottom face
    [1,7,4],
    [1,4,2],
]

def display_screen():
    print("\x1b[H")
    for row in range(num_rows):
        for col in range(num_cols):
            print(screen[row][col], end='')

def clear_screen():
    # Fix: Actually clear the screen by copying the cleared_screen
    screen[:] = [row[:] for row in cleared_screen]

symbols = "$$**..--@@##"
camera_v = vec3(0,0,1)

def draw_cube(rx, ry, rz):
    _ = rx
    _ = rz
    inc = 0
    for triangle in cube_triangles:
        transformed_vertices = []
        for i in range(3):
            # Fix: Create new vec3 objects instead of modifying originals
            vertex = cube_vertices[triangle[i]]
            new_vertex = vec3(vertex.x, vertex.y, vertex.z)
            rotate_around_x(new_vertex, rx)
            rotate_around_y(new_vertex, ry)
            rotate_around_z(new_vertex, rz)
            # push it into the screen
            new_vertex.z += 8
            # scale it
            scale = 66
            new_vertex.y *= scale
            new_vertex.x *= scale * 2.5
            
            transformed_vertices.append(new_vertex)

        v_01 = vec3(
            transformed_vertices[1].x - transformed_vertices[0].x,
            transformed_vertices[1].y - transformed_vertices[0].y,
            transformed_vertices[1].z - transformed_vertices[0].z)
        v_02 = vec3(
            transformed_vertices[2].x - transformed_vertices[0].x,
            transformed_vertices[2].y - transformed_vertices[0].y,
            transformed_vertices[2].z - transformed_vertices[0].z)
        
        normal = cross_product(v_01, v_02)
        
        if dot_product(camera_v, normal) >= 0:
            continue
        projected_points = []
        for j in range(3):
            projected_points.append(project(transformed_vertices[j]))
        draw_triangle(projected_points[0],projected_points[1],projected_points[2], symbols[inc])
        inc += 1

def dot_product(a,b):
    return a.x*b.x + a.y*b.y + a.z*b.z

def cross_product(a, b):
    return vec3(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x)

def rotate_around_x(v, rotation_angle):
    # Store original values to avoid overwriting
    orig_y = v.y
    orig_z = v.z
    v.y = math.cos(rotation_angle)*orig_y + (-math.sin(rotation_angle))*orig_z
    v.z = math.sin(rotation_angle)*orig_y + math.cos(rotation_angle)*orig_z

def rotate_around_y(v, rotation_angle):
    # Store original values to avoid overwriting
    orig_x = v.x
    orig_z = v.z
    v.x = math.cos(rotation_angle)*orig_x + math.sin(rotation_angle)*orig_z
    v.z = (-math.sin(rotation_angle))*orig_x + math.cos(rotation_angle)*orig_z

def rotate_around_z(v, rotation_angle):
    # Store original values to avoid overwriting
    orig_x = v.x
    orig_y = v.y
    v.x = math.cos(rotation_angle)*orig_x + (-math.sin(rotation_angle))*orig_y
    v.y = math.sin(rotation_angle)*orig_x + math.cos(rotation_angle)*orig_y

def project(vec):
    # print(vec.x,vec.z,vec.y)
    # print(round(vec.x/vec.z + num_cols / 2), round(vec.y/vec.z + num_rows / 2))
    return vec2(round(vec.x/vec.z + num_cols / 2), round(vec.y/vec.z + num_rows / 2))


def draw_triangle(vec0, vec1, vec2, symbol):
    v0 = vec0
    v1 = vec1
    v2 = vec2
    # sort verts
    if v0.y > v1.y:
        v0 = vec1
        v1 = vec0
    if v1.y > v2.y:
        tmp = v2
        v2 = v1
        v1 = tmp
    if v0.y > v1.y:
        tmp = v0
        v0 = v1
        v1 = tmp
    # if the triangle is already a flat top or bottom just draw it
    if v2.y == v1.y:
        draw_flat_bottom(v0, v1 , v2, symbol)
        return
    if v0.y == v1.y:
        draw_flat_top(v0, v1 ,v2, symbol)
        return
    # find the mid point vec2
    midpoint.x = (v0.x + (v2.x - v0.x) * (v1.y - v0.y) / (v2.y - v0.y))
    midpoint.y = v1.y
    draw_flat_bottom(v0, v1, midpoint, symbol)
    draw_flat_top(v1, midpoint, v2, symbol)

    

def draw_flat_bottom(t, b0, b1, symbol):
    x_b = t.x
    x_e = t.x
    if b0.y - t.y == 0 or b1.y - t.y == 0:
        return
    x_dec_0 = (t.x-b0.x) / (b0.y - t.y)
    x_dec_1 = (t.x-b1.x) / (b1.y - t.y)

    for y in range(t.y, b0.y + 1):
        draw_scan_line(y, int(x_b), int(x_e), symbol)
        x_b -= x_dec_0
        x_e -= x_dec_1

def draw_flat_top(t0, t1, b, symbol):
    x_b = t0.x
    x_e = t1.x
    if b.y - t0.y == 0 or b.y - t1.y == 0:
        return
    x_inc_0 = (b.x-t0.x) / (b.y - t0.y)
    x_inc_1 = (b.x-t1.x) / (b.y - t1.y)

    for y in range(t0.y, b.y + 1):
        draw_scan_line(y, int(x_b), int(x_e), symbol)
        x_b += x_inc_0
        x_e += x_inc_1

def draw_scan_line(y, x0, x1, symbol):
    left = x0
    right = x1
    if left > right:
        left = x1
        right = x0
    
    # Add bounds checking to prevent out-of-bounds errors
    if y < 0 or y >= num_rows:
        return
        
    for x in range(left, right+1):
        if 0 <= x < num_cols:  # Check x bounds too
            screen[y][x] = symbol


def main():
    print("\x1B[2J\x1B[?25l")
    rx = 0
    ry = 0
    rz = 0
    while(True):
        clear_screen()
        # update
        draw_cube(rx, ry, rz)
        display_screen()
        rx = (rx + 0.1)%(2*math.pi)
        ry = (ry + 0.1)%(2*math.pi)
        rz = (rz + 0.1)%(2*math.pi)

        time.sleep(.1)

if __name__ == "__main__":
    main()