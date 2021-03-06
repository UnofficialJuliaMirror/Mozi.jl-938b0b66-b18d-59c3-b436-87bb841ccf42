function K_eular_shear(beam::Beam)::Matrix{Float64}
    E,ν=beam.material.E,beam.material.ν
    A,I₂,I₃,J,l=beam.section.A,beam.section.I₂,beam.section.I₃,beam.section.J,beam.l
    As₂,As₃=beam.section.As₂,beam.section.As₃
    G=E/2/(1+ν)
    ϕ₂,ϕ₃=12E*I₃/(G*As₂*l^2),12E*I₂/(G*As₃*l^2)
    K=zeros(12,12)
    K[1,1]=E*A/l
    K[2,2]=12E*I₃/l^3/(1+ϕ₂)
    K[3,3]=12E*I₂/l^3/(1+ϕ₃)
    K[4,4]=G*J/l
    K[5,5]=(4+ϕ₃)*E*I₂/l/(1+ϕ₃)
    K[6,6]=(4+ϕ₂)*E*I₃/l/(1+ϕ₂)
    K[7,7]=E*A/l
    K[8,8]=12E*I₃/l^3/(1+ϕ₂)
    K[9,9]=12E*I₂/l^3/(1+ϕ₃)
    K[10,10]=G*J/l
    K[11,11]=(4+ϕ₃)*E*I₂/l/(1+ϕ₃)
    K[12,12]=(4+ϕ₂)*E*I₃/l/(1+ϕ₂)

    K[3,5]=K[5,3]=-6E*I₂/l^2/(1+ϕ₃)
    K[6,8]=K[8,6]=-6E*I₃/l^2/(1+ϕ₂)
    K[9,11]=K[11,9]=6E*I₂/l^2/(1+ϕ₃)

    K[2,6]=K[6,2]=6E*I₃/l^2/(1+ϕ₂)
    K[5,9]=K[9,5]=6E*I₂/l^2/(1+ϕ₃)
    K[8,12]=K[12,8]=-6E*I₃/l^2/(1+ϕ₂)

    K[7,1]=K[1,7]=-E*A/l
    K[8,2]=K[2,8]=-12E*I₃/l^3/(1+ϕ₂)
    K[9,3]=K[3,9]=-12E*I₂/l^3/(1+ϕ₃)
    K[10,4]=K[4,10]=-G*J/l
    K[11,5]=K[5,11]=(2-ϕ₃)*E*I₂/l/(1+ϕ₃)
    K[12,6]=K[6,12]=(2-ϕ₂)*E*I₃/l/(1+ϕ₂)

    K[3,11]=K[11,3]=-6E*I₂/l^2/(1+ϕ₃)

    K[2,12]=K[12,2]=6E*I₃/l^2/(1+ϕ₂)

    return K
end

function K2_eular_shear(beam::Beam)::Matrix{Float64}
    E,ν=beam.material.E,beam.material.ν
    A,I₂,I₃,J,l=beam.section.A,beam.section.I₂,beam.section.I₃,beam.section.J,beam.l
    As₂,As₃=beam.section.As₂,beam.section.As₃
    G=E/2/(1+ν)
    T=σ*A
    ϕ₂,ϕ₃=12E*I₃/(G*As₂*l^2),12E*I₂/(G*As₃*l^2)
    K=zeros(12,12)

    K[2,2]=(6/5+2ϕ₂+ϕ₂^2)/(1+ϕ₂)^2
    K[3,3]=(6/5+2ϕ₃+ϕ₃^2)/(1+ϕ₃)^2
    K[4,4]=J/A
    K[5,5]=(2*l^2/15+l^2*ϕ₃/6+l^2*ϕ₃^2/12)/(1+ϕ₃)^2
    K[6,6]=(2*l^2/15+l^2*ϕ₂/6+l^2*ϕ₂^2/12)/(1+ϕ₂)^2
    K[8,8]=(6/5+2ϕ₂+ϕ₂^2)/(1+ϕ₂)^2
    K[9,9]=(6/5+2ϕ₃+ϕ₃^2)/(1+ϕ₃)^2
    K[10,10]=J/A
    K[11,11]=(2*l^2/15+l^2*ϕ₃/6+l^2*ϕ₃^2/12)/(1+ϕ₃)^2
    K[12,12]=(2*l^2/15+l^2*ϕ₂/6+l^2*ϕ₂^2/12)/(1+ϕ₂)^2

    K[3,5]=K[5,3]=-(l/10)/(1+ϕ₃)^2
    K[6,8]=K[8,6]=-(l/10)/(1+ϕ₂)^2
    K[9,11]=K[11,9]=(l/10)/(1+ϕ₃)^2

    K[2,6]=K[6,2]=(l/10)/(1+ϕ₂)^2
    K[5,9]=K[9,5]=(l/10)/(1+ϕ₃)^2

    K[2,8]=K[8,2]=-(6/5+2ϕ₂+ϕ₂^2)/(1+ϕ₂)^2
    K[3,9]=K[9,3]=-(6/5+2ϕ₃+ϕ₃^2)/(1+ϕ₃)^2
    K[4,10]=K[10,4]=-J/A
    K[5,11]=K[11,5]=-(l^2/30+l^2*ϕ₃/6+l^2*ϕ₃^2/12)/(1+ϕ₃)^2
    K[6,12]=K[12,6]=-(l^2/30+l^2*ϕ₂/6+l^2*ϕ₂^2/12)/(1+ϕ₂)^2

    K[3,11]=K[11,3]=-(l/10)/(1+ϕ₃)^2

    K[2,12]=K[12,2]=(l/10)/(1+ϕ₂)^2

    K*=T/l
    return K
end
