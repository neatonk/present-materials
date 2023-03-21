import type { NextPage } from 'next'
import Head from 'next/head'
import { useContractRead } from 'wagmi'
import { Header } from '../components/Header'
import { Footer } from '../components/Footer'
import * as CurationManager from '../contractABI/CurationManager.json'
import EditionCard from '../components/EditionCard'
import Image from 'next/image'
import { useMemo } from 'react'
import { FutureTapeButton } from '@public-assembly/future-tape'

const Home: NextPage = () => {
  // CuratorContract Read Call --> query array of all active curators
  const { data, isError } = useContractRead({
    addressOrName: '0x6422Bf82Ab27F121a043d6DE88b55FA39e2ea292',
    contractInterface: CurationManager.abi,
    functionName: 'viewAllListings',
    watch: true,
    onError(error) {
      console.log('error: ', isError)
    },
    onSuccess(data) {
      console.log('Array of current collections --> ', data)
    },
  })

  const collectionData = useMemo(() => (data ? data : []), [data])

  const collectionDataReverseOrder = [...collectionData].reverse()

  const rowAndColumnCount = collectionData.length

  return (
    <div className='flex flex-col items-center justify-center h-full min-h-screen scrollbar-thin scrollbar-thumb-black scrollbar-track-gray-600'>
      <Header />
      <Head>
        <title>Present Material</title>
        <meta name='description' content='A Web3 Record Store' />
        <link rel='icon' href='/graphics/1_1.png' />
        <meta name='og:title' content='Songcamp: Present Material' />
        <meta property='og:image' content='https://www.presentmaterial.xyz/graphics/mobile_preview.png' />
        <meta name='twitter:card' content='summary_large_image' />
        <meta name='twitter:description' content='A Web3 Record Store' />

        <meta name='twitter:title' content='Songcamp: Present Material' />

        <meta name='twitter:image' content='https://www.presentmaterial.xyz/graphics/16_9.png' />
        <link rel='icon' href='https://www.presentmaterial.xyz/graphics/mobile_preview.png' />
        <link rel='apple-touch-icon' href='https://www.presentmaterial.xyz/graphics/mobile_preview.png' />
      </Head>

      <div className='relative py-10 border-t-[1px] border-solid border-[#00c2ff] mt-[80px] w-full flex flex-col justify-center items-center'>
        <div>
          <Image src={'/collection_page_graphic_v2.png'} height={227} width={315} />
        </div>
        <div className='p-4 text-xl font-semibold'>
          <FutureTapeButton
            href='present+material'
            color='#00c2ff'
            text='Listen&nbsp;on&nbsp;Future&nbsp;Tape&nbsp;↗︎'
            className='relative inline-block max-w-fit text-[color:var(--future-tape-color)] after:absolute after:bottom-0 after:left-0 after:h-[1px] after:w-full after:origin-bottom-right after:scale-x-0 after:bg-[color:var(--future-tape-color)] after:transition-transform after:duration-[0.4s] after:ease-[cubic-bezier(0.86,0,0.07,1)] hover:after:origin-bottom-left hover:after:scale-x-100'
          />
        </div>
      </div>
      <main
        className={` pb-8 sm:pb-[70px] text-white grid grid-rows-[${rowAndColumnCount}]  flex justify-center lg:grid-cols-3 sm:grid-cols-2  w-[90%] sm:w-[80%]  gap-y-8 sm:gap-y-[70px]  gap-x-0 sm:gap-x-[70px]`}
      >
        {collectionDataReverseOrder.map((collection, index) => (
          <EditionCard editionAddress={collectionDataReverseOrder[index]} totalCurated={rowAndColumnCount} index={index} key={collection} />
        ))}
      </main>
      <Footer />
    </div>
  )
}

export default Home
