c1 = [-37,36.5];
c2 = [-16,149];
r1 = 60;
r2 = 62.5;
r3 = 125;

dirtyPreview=false;
renderShell=false;

boardoffset=4-0.5;
holeexp=0.;
holes = [
    [[21,21.0,6.5],15,8.0+holeexp],
    [[23,36.5,7.0], 0,6.5+holeexp],
    [[22,49.5,7.0], 0,6.5+holeexp],
    [[22,62.5,7.0], 0,6.5+holeexp],
];
shellheight=19;
shellTolerance=0.15;
pilotHole=true;

epsilon = 0.001;
cdetail = $preview?4:1;

module prerender(convexity=undef) {
    if(!dirtyPreview) {
        render(convexity) children();
    } else {
        children();
    }
}

function vlen(v) = sqrt(v.x*v.x+v.y*v.y);
function distAlongV(v,d) = v*d/vlen(v);
function cfn(r) = max(8,ceil(2*PI*r/cdetail));

function intersectTwoCircles(c1,r1,c2,r2) =
    let(x1=c1.x,y1=c1.y,x2=c2.x,y2=c2.y,
    centerdx = x1-x2, centerdy = y1-y2,
    R = sqrt(centerdx*centerdx + centerdy*centerdy),
    ttol=1e-4)
    (abs(r1-r2)<=R+ttol && r1+r2>=R-ttol) ? let(
        a = (r1*r1-r2*r2) / (2*R*R),
        r2r2 = (r1*r1-r2*r2),
        c = sqrt(max(0,2*(r1*r1+r2*r2)/(R*R)
            - (r2r2*r2r2)/(R*R*R*R) - 1)),
        fx = (x1+x2)/2 + a*(x2-x1),
        gx = c*(y2-y1)/2,
        ix1 = fx+gx,
        ix2 = fx-gx,
        fy = (y1+y2)/2 + a*(y2-y1),
        gy = c*(x1-x2)/2,
        iy1 = fy+gy,
        iy2 = fy-gy
    ) [[ix1, iy1], [ix2, iy2]] : [];

function intersectLineCircle(p1,p2,c,r) =
    let(cx=c.x,cy=c.y,p1c=p1-c,p2c=p2-c,
    x1=p1c.x,y1=p1c.y,x2=p2c.x,y2=p2c.y,
    dx=x2-x1,dy=y2-y1,dr=sqrt(dx*dx+dy*dy),
    D=x1*y2-x2*y1,
    k=r*r*dr*dr-D*D)
    (k>=0) ? let(
        dr2=dr*dr,
        kd=sqrt(k)/dr2,
        fx=D*dy/dr2+cx,
        gx=(dy<0?-1:1)*dx*kd,
        ix1=fx+gx,
        ix2=fx-gx,
        fy=(-1)*D*dx/dr2+cy,
        gy=abs(dy)*kd,
        iy1=fy+gy,
        iy2=fy-gy
    ) [[ix1, iy1], [ix2, iy2]] : [];

module outerCircles(h,off,sl) union() {
    r1a = r1-off;
    r2a = r2-off;
    r1b = r1a-h*sl;
    r2b = r2a-h*sl;
    translate(c1)
        cylinder(h=h,r1=r1b,r2=r1a,$fn=cfn(r1));
    //translate(c2)
    //    cylinder(h=h,r1=r2b,r2=r2a,$fn=cfn(r2));
}

c3 = intersectTwoCircles(c1,r1+r3,c2,r2+r3)[0];
module innerCircleFill(h,off,sl) {
    r3a = r3+off;
    r3b = r3a+h*sl;
    rs=max(0,-h*sl);
    ip1 = c1+distAlongV(c3-c1,r1-off+rs);
    ip2 = c2+distAlongV(c3-c2,r2-off+rs);
    
    prerender(convexity=10)
    difference() {
        linear_extrude(h)
        hull() {
            translate(c1) circle(r=epsilon);
            translate(ip1) circle(r=epsilon);
            translate(ip2) circle(r=epsilon);
            translate(c2) circle(r=epsilon);
        }
        translate([0,0,-epsilon])
        translate(c3) cylinder(h=h+2*epsilon,
            r1=r3b,r2=r3a,$fn=cfn(r3));
    }
}

module inclusionShape(h,xoff) {
    translate([0,0,-epsilon])
    linear_extrude(h+2*epsilon)
    polygon([
        [-xoff,xoff],[50,-50],[50,75],
        [-xoff,75+(50+xoff)/5]
    ]);
}

module endRoundProfile() {
    tol=shellTolerance;
    ww=3;
    xo=(4.5+ww)/2+tol;
    yo=0;
    ch1=shellheight+1-4.5;
    ch2=shellheight+1-2.0;
    union() {
        translate([-xo,yo,4.5])
            cylinder(h=ch1,d=ww,$fn=cfn(ww)*2);
        translate([xo,yo,2.0])
            cylinder(h=ch2,d=ww,$fn=cfn(ww)*2);
        translate([0,0,shellheight+1+3])
        rotate([90,0,0])
        linear_extrude(ww,center=true)
        polygon([
            [-xo-ww/2-1.5,0],
            [-xo-ww/2,-3],
            [xo+ww/2,-3],
            [xo+ww/2+1.5  ,0]
        ]);
    }
}

module endRounds() {
    ep1 = intersectLineCircle([0,0],[50,-50],
        c1,r1-2.25)[1];
    ea1 = 45;
    ep2 = intersectLineCircle([0,85],[50,75],
        c3,r3+2.25)[0];
    ea2 = atan(1/5);
    ch = shellheight+1;
    translate(ep1) rotate([0,0,-ea1])
        endRoundProfile();
    translate(ep2) rotate([0,0,-ea2])
        endRoundProfile();
}

module previewShell() {
    h=shellheight;
    color("#8AF")
    //prerender()
    difference() {
        intersection() {
            difference() {
                union() {
                    outerCircles(h,0,0.07);
                    innerCircleFill(h,0,0.07);
                }
                translate([0,0,3])
                union() {
                    outerCircles(h,4.5,0);
                    innerCircleFill(h,4.5,0);
                }
            }
            inclusionShape(h,0);
        }
        for(hole = holes) {
            hpos = hole[0];
            hangl = hole[1];
            hdiam = hole[2];
            translate([hpos[0],hpos[1],
                h-hpos[2]-boardoffset])
            rotate([0,90,-hangl])
            cylinder(h=10,d=hdiam,
                center=true,$fn=cfn(hdiam/2)*2);
        }
    }
}

module drillGuide() {
    hb=shellheight+1;
    h1=hb-4.5;
    h2=hb-2.0;
    tol=shellTolerance;
    ww=3;
    color("#EEE",0.5)
    prerender()
    union() {
        difference() {
            intersection() {
                union() {
                    // Inner
                    translate([0,0,4.5])
                    difference() {
                        union() {
                            outerCircles(h1,
                                4.5+tol,0);
                            innerCircleFill(h1,
                                4.5+tol,0);
                        }
                        translate([0,0,-epsilon])
                        union() {
                            outerCircles(h1+1,
                                4.5+ww+tol,0);
                            innerCircleFill(h1+1,
                                4.5+ww+tol,0);
                        }
                    }
                    // Outer
                    translate([0,0,2.0])
                    difference() {
                        union() {
                            outerCircles(h2,
                                -ww-tol,0);
                            innerCircleFill(h2,
                                -ww-tol,0);
                        }
                        translate([0,0,-epsilon])
                        union() {
                            outerCircles(h2+1,
                                -tol,0);
                            innerCircleFill(h2+1,
                                -tol,0);
                        }
                    }
                    // Base
                    translate([0,0,hb])
                    difference() {
                        union() {
                            outerCircles(3,
                                -ww-tol-1.5,0.5);
                            innerCircleFill(3,
                                -ww-tol-1.5,0.5);
                        }
                        translate([0,0,-1+epsilon])
                        union() {
                            outerCircles(4,
                                4.5+ww+tol+1.5,-0.5);
                            innerCircleFill(4,
                                4.5+ww+tol+1.5,-0.5);
                        }
                    }
                    // Vert aligner
                    vac=0.8-tol;
                    translate([0,0,
                        shellheight+epsilon])
                    difference() {
                        union() {
                            outerCircles(1,vac,0.2);
                            innerCircleFill(1,vac,0.2);
                        }
                        translate([0,0,-1+epsilon])
                        union() {
                            outerCircles(2,
                                4.5-vac,-0.2);
                            innerCircleFill(2,
                                4.5-vac,-0.2);
                        }
                    }
                }
                inclusionShape(hb+3,5);
            }
            for(hole = holes) {
                hpos = hole[0];
                hangl = hole[1];
                hdiam = hole[2];
                translate([hpos[0],hpos[1],
                    shellheight-hpos[2]-boardoffset])
                rotate([0,90,-hangl]) union() {
                    if(pilotHole) {
                        phd=2.5;
                        cylinder(h=50,d=phd,
                            center=false,
                            $fn=cfn(hdiam/2)*2);
                        translate([0,0,tol+1])
                        cylinder(h=50,d1=phd-epsilon,
                            d2=hdiam+102.5,
                            center=false,
                            $fn=cfn(hdiam/2)*2);
                        rotate([180,0,0])
                        cylinder(h=50,d=phd+1,
                            center=false,
                            $fn=cfn(hdiam/2)*2);
                    } else {
                        cylinder(h=50,d=hdiam,
                            center=false,
                            $fn=cfn(hdiam/2)*2);
                        rotate([180,0,0])
                        hull() {
                            cylinder(h=50,d=hdiam,
                                center=false,
                                $fn=cfn(hdiam/2)*2);
                            translate([20,0,0])
                            cylinder(h=50,d=hdiam,
                                center=false,
                                $fn=cfn(hdiam/2)*2);
                        }
                    }
                }
                // Angle lines
                translate([hpos[0],hpos[1],
                    shellheight+1+3])
                rotate([0,90,-hangl])
                cylinder(h=50,center=true,
                    d=1.2,$fn=16);
            }
        }
        endRounds();
    }
}

module printPosition() {
    h=shellheight+1-4.5;
    h2=h+2.5;
    translate([0,0,h2+1+4]) rotate([180,0,0])
    children();
}

if($preview) {
    previewShell();
    if(!renderShell) drillGuide();
} else {
    if(renderShell) {
        previewShell();
    } else {
        printPosition() drillGuide();
    }
}
