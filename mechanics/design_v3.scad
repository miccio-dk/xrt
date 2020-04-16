// MODEL PARAMS (mm) //
th = 3; // thickness 
w = 350; // width 
d = 240; // depth
h = 20; // height
bor = 22 / 2; // bearing outer radius
bir = 8 / 2; // bearing inner radius
bdr = (d/2-th*4); // base disk radius
nd = 8; // number of disks
kerf = 0; // kerf for 3mm mdf

nis = 3; // number of inner sides
nsb = 5; // number of support bars
sbw = h-th*2;   // support bars width


// RUNTIME PARAMS //
$fn = 32;
vo = 10 * pow(1-$t, 4); // animation
vo = 0; // offset
k = 0.05; // zbuffer semi-fix


//disk_tr(0.25, 25);
assembly();
//projection(cut = false) assembly_flat();

// normal assembly
module assembly() {
    // outer walls
    translate([-vo,     0,       vo]) side(nsb);
    translate([-vo,     0,       vo]) support_bars(nsb);
    translate([-vo,     0,       vo]) inner_sides(nsb);
    translate([w-th+vo, 0,       vo]) side(nsb);
    // spinning parts
    translate([0,       d/2,     h+bdr+vo*2]) rotate([0, 90, 0]) rod();
    translate([0,       d/2,     h+bdr+vo*2]) rotate([0, 90, 0]) disks();
    translate([0,       d/2,     h+bdr+vo*2]) rotate([0, 90, 0]) bearings();
}

// flat assembly
module assembly_flat() {
    color("blue") {
        // outer walls
        base();
        translate([w+th, 0,    0]) top();
        translate([(w+th)*2, 0, th]) rotate([0, 90, 0]) side();
        translate([(w+h+sh+sr)*2+th*3, 0, 0]) rotate([0, -90, 0]) side();
        // spinning parts
        *translate([0, 0, 0]) rod();
        translate([th*4+(w+h+sh+sr)*2+dr, d/2, -w/(nd+1)]) 
        disks();
    }
}


// STRUCTURE //

module base() {
    difference() {
        cube([w, d, th]);
        teeths("w", ntw, true);
        teeths("d", ntd, true);
        translate([0, d-th, 0]) teeths("w", ntw, true);
        translate([w-th, 0, 0]) teeths("d", ntd, true);
    }
}

module inner_sides(nsb) {
    for(i = [1:1:nis]) {
            translate([(w-w/(nd+1))/(nis+1)*i+w/(nd+1)/2, 0, 0]) side(nsb);
        }
}

// nsb: number of support bars
module side(nsb) {
    tdr = (d-bdr*2)/2;    // top disk radius
    difference() {
        union() {
            cube([th, d, h+bdr]);
            translate([0, d/2, h+bdr])
              rotate([0, 90, 0]) cylinder(th, tdr, tdr, $fn=128);
        };
        translate([-k/2, d-th*2, th]) cube([th+k, th, sbw]);
        translate([-k/2, th,   th]) cube([th+k, th, sbw]);
        
        for(i = [0:1:nsb-1]) {
            translate([-k/2, th*3+(d-sbw-th*6)/(nsb-1)*i,   th]) cube([th+k, sbw, th]);
        }

        translate([-k/2, d/2, h+bdr]) rotate([0, 90, 0]) cylinder(th+k, bir-kerf, bir-kerf);
        translate([-k/2, d, h+bdr-k*2]) rotate([0, 90, 0]) cylinder(th+k, bdr, bdr, $fn=128);
        translate([-k/2, 0, h+bdr]) rotate([0, 90, 0]) cylinder(th+k, bdr, bdr, $fn=128);
    }
}

module support_bars(nsb) {
    for(i = [0:1:nsb-1]) {
        translate([-th, th*3+(d-sbw-th*6)/(nsb-1)*i, th]) cube([w+th*2, sbw, th]);
    }
}



// SPINNING PARTS //

module rod() {
    color("lightgray") {
        cylinder(w, bir, bir);
    }
}

module bearings() {
    color("grey") {
        for(i = [1:1:nd]) {
            translate([0, 0, w/(nd+1)*i]) bearing();
        }
    }
}

module bearing() {
    bd = 7; // bearing depth
    difference() {
        translate([0,0,-(bd-th)/2]) cylinder(bd, bor, bor);
        translate([0,0,-(bd-th+k)/2]) cylinder(bd+k, bir, bir);
        
    }
}

// drm: disk radius multiplier
// nt: number of teeth
// td: teeth depth
// dc: duty cycle
module disk(drm, nt, td, dc) {
    // current disk radius = base disk radius * multiplier
    cdr = bdr * drm; 
    difference() {
        cylinder(th, cdr, cdr, $fn=128);
        translate([0,0,-k/2]) cylinder(th+k, bor-kerf, bor-kerf);
        tw = cdr*2*PI / nt; // teeth height
        for(i = [1:1:nt]) {
            rotate([0, 0, 360/nt*i]) 
            translate([-tw/2, cdr-td, -k/2]) 
            cube([tw*(1-dc), td, th+k]);
        }
    }
}

// trigger disk
// tl: trigger length
module disk_tr(drm, tl) {
    cdr = bdr * drm; // current disk radius = base disk radius * multiplier
    hr = tl/2 - 5; // handle hole radius
    ttw = 4; // trigger tooth width
    union() {
        difference() {
            cylinder(th, cdr, cdr, $fn=128);
            translate([0,0,-k/2]) cylinder(th+k, bor-kerf, bor-kerf);
        };
        // handle
        rotate([0, 0, 90]) difference() {
            union() {
                translate([-tl/2, cdr-th, 0]) cube([tl, tl/2, th]);
                translate([0, cdr-th+tl/2, 0]) cylinder(th, tl/2, tl/2);
            };
            translate([0, cdr-th+tl/2, -k/2]) cylinder(th+k, hr, hr);
        }
        rotate([0, 0, 0]) translate([-ttw/2, cdr-th, 0]) cube([ttw, ttw*4, th]);
    }
}

module disks() {
    translate([0, 0, w/(8+1)*1]) disk_tr(0.25, 25);
    
    translate([0, 0, w/(8+1)*2]) disk(0.5,  64,      6, 0.5);
    translate([0, 0, w/(8+1)*3]) disk(0.75, 96*1.5,  4, 0.5);
    translate([0, 0, w/(8+1)*4]) disk(1,    128*0.5, 8, 0.5);
    translate([0, 0, w/(8+1)*5]) disk(1,    128*0.5, 4, 0.25);
    translate([0, 0, w/(8+1)*6]) disk(0.75, 96,      8, 0.75);
    translate([0, 0, w/(8+1)*7]) disk(0.5,  64*1.5,  4, 0.5);
    
    translate([0, 0, w/(8+1)*8]) disk_tr(0.25, 25);
}