// MODEL PARAMS (mm) //
th = 3; // thickness 
w = 400; // width 
d = 350; // depth
h = 150; // height
bor = 22 / 2; // bearing outer radius
bir = 8 / 2; // bearing inner radius
sr = 22; // support radius
sh = 30; // support height 
bdr = (d/2-th*4); // base disk radius
nd = 8; // number of disks
kerf = 0; // kerf for 3mm mdf

ntw = 15;
ntd = 7;
nth = 2;

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
    base();
    translate([0,        0,      h-th+vo*2]) top();
    translate([0,       -vo,     vo]) side_long();
    translate([0,       d-th+vo, vo]) side_long();
    translate([-vo,     0,       vo]) side_short();
    translate([w-th+vo, 0,       vo]) side_short();
    // spinning parts
    translate([0,       d/2,     h+sh+vo*2]) rotate([0, 90, 0]) rod();
    translate([0,       d/2,     h+sh+vo*2]) rotate([0, 90, 0]) disks();
}

// flat assembly
module assembly_flat() {
    color("blue") {
        // outer walls
        base();
        translate([w+th, 0,    0]) top();
        translate([th*3+w*2+h, 0, th]) rotate([-90, 0, 0]) side_long();
        translate([th*3+w*2+h, d-h, th]) rotate([-90, 0, 0]) side_long();
        translate([(w+th)*2, 0, th]) rotate([0, 90, 0]) side_short();
        translate([(w+h+sh+sr)*2+th*3, 0, 0]) rotate([0, -90, 0]) side_short();
        // spinning parts
        *translate([0, 0, 0]) rod();
        translate([th*4+(w+h+sh+sr)*2+dr, d/2, -w/(nd+1)]) 
        disks();
    }
}

// OUTER WALLS //

module base() {
    difference() {
        cube([w, d, th]);
        teeths("w", ntw, true);
        teeths("d", ntd, true);
        translate([0, d-th, 0]) teeths("w", ntw, true);
        translate([w-th, 0, 0]) teeths("d", ntd, true);
    }
}

module side_long() {
    difference() {
        cube([w, th, h]);
        teeths("h", nth, false);
        teeths("w", ntw, false);
        translate([w-th, 0, 0]) teeths("h", nth, false);
        translate([0, 0, h-th]) teeths("w", ntw, false);
    }
}

module side_short() {
    difference() {
        union() {
            cube([th, d, h]);
            translate([0, (d-sr*2)/2, h]) cube([th, sr*2, sh]);
            translate([0, d/2, h+sh])
              rotate([0, 90, 0]) cylinder(th, sr, sr);
        };
        teeths("h", nth, true);
        teeths("d", ntd, false);
        translate([0, d-th, 0]) teeths("h", nth, true);
        translate([0, 0, h-th]) teeths("d", ntd, false);
        translate([0, d/2, h+sh])
          rotate([0, 90, 0]) translate([0,0,-k/2]) cylinder(th+k, bir-kerf, bir-kerf);
    }
}

module top() {
    difference() {
        cube([w, d, th]);
        teeths("w", ntw, true);
        teeths("d", ntd, true);
        translate([0, d-th, 0]) teeths("w", ntw, true);
        translate([w-th, 0, 0]) teeths("d", ntd, true);
        m = [0, 0.35, 0.5, 0.75, 1, 1, 0.75, 0.5, 0.35];
        for(i = [1:1:nd]) {
            cdr = bdr*m[i];
            translate([w/(nd+1)*i-th, d/2-cdr-th, -k/2]) cube([th*3, (cdr+th)*2, th+k]);
        }
    }
}


// SPINNING PARTS //

module rod() {
    cylinder(w, bir, bir);
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


// TOOLS //

// tabs on the box sides
// axis/side, number of tabs, polarity
module teeths(s, nt, p) {
    lmax = (s=="w" ? w : (s=="d" ? d : h));
    tl = lmax / nt / 2; // lenght of tab
    po = (p ? 0 : tl); // 
    
    for(i = [0:tl*2:lmax+tl]) {
        offs = [
            s=="w"? -tl/2 : 0,
            s=="d"? -tl/2 : 0,
            s=="h"? -tl/2 : 0
        ];
        translate(offs)
          translate([
                s=="w"? i+po+kerf : 0,
                s=="d"? i+po+kerf : 0,
                s=="h"? i+po+kerf : 0
            ])
            cube([
                s=="w"? tl-kerf : th+k, 
                s=="d"? tl-kerf : th+k, 
                s=="h"? tl-kerf : th+k, 
            ]);
    }
}