import SciLean.Data.Mesh.PrismaticMesh
import SciLean.Data.DataArray

namespace SciLean

structure TriangularSet.FaceData where
  pointCount : Nat
  edgeCount  : Nat
  triangleCount : Nat

  edgePoints    : (Fin pointCount)^{edgeCount, 2}
  triangleEdges : (Fin edgeCount)^{triangleCount, 3}

  -- TODO: Add proposition that it is consistent

open Prism in
structure TriangularSet.CofaceData extends FaceData where
  pointEdges     : ArrayN (Array (Inclusion point segment × Fin edgeCount)) pointCount
  pointTriangles : ArrayN (Array (Inclusion point triangle × Fin triangleCount)) pointCount
  edgeTriangles  : ArrayN (Array (Inclusion segment triangle × Fin triangleCount)) edgeCount


-- TODO: Define few predicates on TriangularSet.FaceData
--     1. it is consistent
--     2. it is a manifold i.e. each edge has one or two neighbours
--     3. does not have boundary i.e. every edge has at least two neighbours (does not have to be manifold e.g. double bubble)

open Prism in
def TriangularSet (data : TriangularSet.FaceData) : PrismaticSet :=
{
  Elem := λ P =>
    match P with
    | point    => Fin data.pointCount
    | segment  => Fin data.edgeCount
    | triangle => Fin data.triangleCount
    | _ => Empty

  face := λ {Q P} ι e => 
    match Q, P, ι with
    -- faces of a point
    | point, point, ⟨.point, _, _⟩ => e

    -- facese of an edge
    -- TODO: use conversion of a face to Fin
    |  point,  segment, ⟨.base .point, _, _⟩ => data.edgePoints[e,0]
    |  point,  segment,  ⟨.tip .point, _, _⟩ => data.edgePoints[e,1]
    | segment, segment, ⟨.cone .point, _, _⟩ => e

    -- facese of a triangle
    -- TODO: use conversion of a face to Fin
    | point, triangle, ⟨.base (.base .point), _, _⟩ => 
      let edge := data.triangleEdges[e,0]
      data.edgePoints[edge,0]
    | point, triangle, ⟨.base (.tip .point), _, _⟩  =>
      let edge := data.triangleEdges[e,0]
      data.edgePoints[edge,1]
    | point, triangle, ⟨.tip (.cone .point), _, _⟩  => 
      let edge := data.triangleEdges[e,1]
      data.edgePoints[edge,1]
    |  segment, triangle, ⟨.base (.cone .point), _, _⟩ => data.triangleEdges[e,0]
    |  segment, triangle, ⟨.cone (.base .point), _, _⟩ => data.triangleEdges[e,1]
    |  segment, triangle,  ⟨.cone (.tip .point), _, _⟩ => data.triangleEdges[e,1]
    | triangle, triangle, ⟨.cone (.cone .point), _, _⟩ => e

    | _, _, _ => 
      /- In all remaining cases `e` is an element of `Empty` -/
      absurd (a:=True) sorry_proof sorry_proof 


  face_comp := sorry_proof
}

open Prism in
instance (data : TriangularSet.CofaceData) : (TriangularSet data.toFaceData).Coface where

  CofaceIndex := λ {Q} e P =>
    match Q, P with
    -- point neighbours
    | point, point    => Unit
    | point, segment  => 
      let e : Fin data.pointCount := reduce_type_of e
      Fin data.pointEdges[e].size
    | point, triangle => 
      let e : Fin data.pointCount := reduce_type_of e
      Fin data.pointTriangles[e].size

    -- edge neighbours
    | segment, segment  => Unit
    | segment, triangle => 
      let e : Fin data.edgeCount := reduce_type_of e
      Fin data.edgeTriangles[e].size

    -- triagnle neighbours
    | triangle, triangle => Unit

    | _, _ => Empty
  
  coface := λ {Q} e P id =>
    match Q, P with
    
    | point, point => 
      (⟨.point, sorry_proof, sorry_proof⟩, e)
    | point, segment => 
      data.pointEdges[reduce_type_of e][id]
    | point, triangle =>
      data.pointTriangles[reduce_type_of e][id]

    | segment, segment => 
      let e : Fin data.edgeCount := e
      (⟨.cone .point, sorry_proof, sorry_proof⟩, e)
    | segment, triangle =>
      data.edgeTriangles[reduce_type_of e][id]

    | triangle, triangle => 
      let e : Fin data.triangleCount := e
      (⟨.cone (.cone .point), sorry_proof, sorry_proof⟩, e)

    | _, _ => 
      /- In all remaining cases `id` is an element of `Empty` -/
      absurd (a:=True) sorry_proof sorry_proof 


  face_coface := sorry_proof
