{-# OPTIONS --universe-polymorphism #-}

module Categories.Free where

open import Categories.Operations
open import Categories.Category
open import Categories.Free.Core
open import Categories.Free.Functor
open import Categories.Quivers.Underlying
open import Categories.Functor
  using (Functor)
open import Graphs.Quiver hiding (_[_,_])
open import Graphs.Quiver.Morphism
  using (QuiverMorphism; module QuiverMorphism)
open import Data.Star

-- Exports from other modules:
--    Free₀, Free₁ and Free
open Categories.Free.Core public
  using (Free₀)
open Categories.Free.Functor public
  using (Free)

-- TODO:
--  Prove Free⊣Underlying : Adjunction Free Underlying
--  Define Adjunction.left and Adjunction.right as conveniences
--    (or whatever other names make sense for the hom-set maps
--    C [ F _ , _ ] → D [ _ , G _ ] and inverse, respectively)
--  Let Cata = Adjunction.left Free⊣Underlying
Cata : ∀{o₁ a₁}{G : Quiver   o₁ a₁}
        {o₂ a₂}{C : Category o₂ a₂}
  → (F : QuiverMorphism G (Underlying₀ C))
  → Functor (Free₀ G) C
Cata {G = G} {C = C} F = record
  { F₀            = F₀
  ; F₁            = F₁*
  ; identity      = refl
  ; homomorphism  = λ{X}{Y}{Z}{f}{g} → homomorphism {X}{Y}{Z}{f}{g}
  }
  where
    open Category C
    open QuiverMorphism F
    open Equiv
    open HomReasoning
    
    F₁* : ∀ {A B} → Free₀ G [ A , B ] → C [ F₀ A , F₀ B ]
    F₁* ε = id
    F₁* (f ◅ fs) = F₁* fs ∘ F₁ f
    
    .homomorphism : ∀ {X Y Z} {f : Free₀ G [ X , Y ]} {g : Free₀ G [ Y , Z ]}
                  → C [ F₁* (Free₀ G [ g ∘ f ]) ≡ C [ F₁* g ∘ F₁* f ] ]
    homomorphism {f = ε} = sym identityʳ
    homomorphism {f = f ◅ fs}{gs} =
      begin
        F₁* (fs ◅◅ gs) ∘ F₁ f
      ↓⟨ homomorphism {f = fs}{gs} ⟩∘⟨ refl ⟩
        (F₁* gs ∘ F₁* fs) ∘ F₁ f
      ↓⟨ assoc ⟩
        F₁* gs ∘ F₁* fs ∘ F₁ f
      ∎